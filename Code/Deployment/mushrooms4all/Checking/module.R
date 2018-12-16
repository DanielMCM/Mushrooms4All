###################################################
##########         Checking Module         ########
###################################################

results_path <- "Checking/"

# UI

checking_ui <- function(id) {
    ns <- NS(id)
    tabPanel(
        title = "Check your mushroom",
        fluidRow(
            box(width = 4, radioGroupButtons(inputId = ns("section"), choices = c("Custom mushroom", "From file"), justified = FALSE, individual = TRUE)),
            box(width = 4, class = "text-right", shinyjs::disabled(actionButton(ns("button_predict"), "Is it edible?"))),
            box(width = 4, selectizeInput(ns("prediction_model"), "Choose model", choices = c("Boosted", "Decision tree", "Random forest"), options = list(placeholder = "Choose a predictive model")))),
        fluidRow(id = ns("one_mushroom_section"),
            box(width = 12, h3(class = "checking-subtitle", "How is your mushroom?")),
            box(selectizeInput(ns('features'), "Features of your mushroom", choices = features, multiple = TRUE, options = list(placeholder = 'Write here the features of your mushroom (by name or category)')),
                div(class = "w-100", actionButton(ns("button_random"), "Random mushroom"))),
            HTML("<label>Summary</label>"),
            verbatimTextOutput(ns('summary'))),
        shinyjs::hidden(fluidRow(id = ns("multiple_mushroom_section"),
            box(width = 12, h3(class = "checking-subtitle", "Check them all!")),
            box(class = "checking-picker-column text-right", title = h4("Choose a CSV file"), fileInput(ns("input_csv_file"), NULL, accept = c("text/csv", "text/comma-separated-values,text/plain", ".csv"))))),
        fluidRow(
            box(width = 12, h4("Results"),
            verbatimTextOutput(ns("prediction")))))
}

# Server

checking_server <- function(input, output, session) {

    # Observers

    # Section switcher
    observe({
        req(input$section)

        shinyjs::toggle("one_mushroom_section", condition = input$section == "Custom mushroom")
        shinyjs::toggle("multiple_mushroom_section", condition = input$section == "From file")
    })

    # Input file
    observe({
        req(input$input_csv_file) # Only when file is chosen

        # Read data
        data <- read.table(input$input_csv_file$datapath, header = TRUE, sep = ",", na.strings = "NONE", quote = "")
        data <- data[complete.cases(data),]
        colnames(data) <- gsub("\\.", "_", colnames(data))

        # Save dataset
        values$chk_mushrooms <<- data
        values$chk_mushrooms_columns <<- colnames(data)
        chk_mushrooms_columns <<- colnames(data)

        # Enable run model
        shinyjs::enable("button_predict")
    })

    # Watch features and update options
    observe({
        req(input$features)

        choices <- calculate_features(input$features)
        values$features_selected <<- input$features
        values$features <<- choices

        updateSelectizeInput(session, 'features', choices = choices, selected = input$features, server = FALSE)
    })

    # Enable/disable predict button
    observe({
        req(input$features)
        shinyjs::toggleState("button_predict", length(input$features) >= 22)
    })

    # Watch features_selected and update mushroom.
    observe({
        req(values$features_selected)
        if (length(values$features_selected) == 0) {
            return("Select features")
        }

        pairs <- strsplit(values$features_selected, "::")
        columns <- unlist(lapply(pairs, `[[`, 1))
        values <- unlist(lapply(pairs, `[[`, 2))

        details <- data.frame(columns, values)
        names <- c()
        for (i in 1:nrow(details)) {
            column <- as.character(details[i, 1][1])
            code <- as.character(details[i, 2][1])
            names[i] <- code_value_dictionary$name[code_value_dictionary$column == column & code_value_dictionary$code == code]
        }
        details[, 3] <- names
        details <- details[, c(1, 3, 2)]

        # update mushroom
        values$mushroom <<- details
    })

    # Random button click. Randomize mushroom.
    observeEvent(input$button_random, {
        random_features <- random_selection()
        choices <- calculate_features(random_features)
        values$features_selected <<- random_features
        values$features <<- choices

        updateSelectizeInput(session, 'features', choices = choices, selected = choices, server = FALSE)
    })

    # Predict button click. 
    observeEvent(input$button_predict, {
        req(input$prediction_model)

        input_to_predict <- NULL

        if (isolate(input$section) == "Custom mushroom") {

            req(values$mushroom)

            # random mushroom

            random_mushroom <- values$mushroom[, -2]
            random_mushroom <- as.data.frame(t(random_mushroom))
            rownames(random_mushroom) <- NULL
            colnames(random_mushroom) <- gsub("-", "_", as.character(unlist(random_mushroom[1,])))
            random_mushroom <- random_mushroom[-1,]

            # get valid mushroom

            mushrooms <- read.csv(file = "../../../Sample_Data/Raw/mushrooms_v2 (prob 0.05).csv")
            column_names <- gsub("\\.", "_", colnames(mushrooms))
            colnames(mushrooms) <- column_names
            for (name in column_names) {
            mushrooms[[name]] <- factor(mushrooms[[name]], levels = levels(mushrooms[[name]]))
            }
            mushroom <- mushrooms[1, -1]

            # parse values

            for (name in colnames(mushroom)) {
                mushroom[[name]] <- random_mushroom[[name]]
            }

            input_to_predict <- mushroom

        } else {

            req(values$chk_mushrooms)
            input_to_predict <- values$chk_mushrooms
        }

        # predict mushroom

        results <- switch(input$prediction_model,
                          "Boosted" = predict_boosted(input_to_predict),
                          "Decision tree" = predict_decisiontree(input_to_predict),
                          "Random forest" = predict_randomforest(input_to_predict))

        values$prediction <- results
    })

    # Prediction functions

    predict_boosted <- function(mushrooms) {

        # Build input

        column_names <- list("cap-shape", "cap-surface", "cap-color", "bruises", "odor", "gill-attachment", "gill-spacing", "gill-size", "gill-color", "stalk-shape", "stalk-root", "stalk-surface-above-ring", "stalk-surface-below-ring", "stalk-color-above-ring", "stalk-color-below-ring", "veil-type", "veil-color", "ring-number", "ring-type", "spore-print-color", "population", "habitat")

        values <- list()
        for (i in 1:nrow(mushrooms)) {
            values[[i]] <- unlist(as.list(mushrooms[i,]), use.names = FALSE)
        }

        input <- list("ColumnNames" = column_names, "Values" = values)
        
        # Predict

        results <- azureml_predict_boosted(input)

        predicted_mushroom <- as.data.frame(t(as.data.frame(matrix(unlist(results$Results$output1$value$Values), nrow = length(unlist(results$Results$output1$value$Values[1]))))))[,23:24]
        colnames(predicted_mushroom) <- c("class", "probs")
        rownames(predicted_mushroom) <- NULL

        return(predicted_mushroom)
    }

    predict_randomforest <- function(mushroom) {
        model.rf <- readRDS("Models/RandomForest.RData")
        results <- predict(model.rf, mushroom)
        return(results)
    }

    predict_decisiontree <- function(mushroom) {
        tree <- readRDS("Models/DecisionTree.RData")
        results <- predict(tree, mushroom, type = 'class')
        results <- as.data.frame(results)
        colnames(results) <- c("class")
        return(results)
    }

    # Renders

    output$summary <- renderPrint({
        req(values$mushroom)
        mushroom <- values$mushroom
        colnames(mushroom) <- c("Feature", "Value", "Code")
        return(mushroom)
    })

    output$prediction <- renderPrint({
        req(values$prediction)
        return(values$prediction)
    })
}
