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
            box(h3(class = "checking-subtitle", "How is your mushroom?")),
            box(class = "text-right", shinyjs::disabled(actionButton(ns("button_predict"), "Is it edible?")))),
        fluidRow(
            box(selectizeInput(ns('features'), NULL, choices = features, multiple = TRUE, options = list(placeholder = 'Write here the features of your mushroom (by name or category)')),
                div(class = "w-100", actionButton(ns("button_random"), "Random mushroom")),
                verbatimTextOutput(ns("prediction"))),
            box(verbatimTextOutput(ns('summary')))))
}

# Server

checking_server <- function(input, output, session) {

    # Observers

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
        req(values$mushroom)
        mushroom <- values$mushroom[,-2]
       
        mushroom <- as.data.frame(t(mushroom))
        rownames(mushroom) <- NULL
        colnames(mushroom) <- as.character(unlist(mushroom[1,]))
        mushroom <- mushroom[-1,]

        load("Models/RandomForest.RData")

        values$prediction <<- predict(model.rf, mushroom)
        print(isolate(values$prediction))
    })

    # Renders

    output$summary <- renderPrint({
        req(values$mushroom)
        mushroom <- values$mushroom
        colnames(mushroom) <- c("Feature", "Value", "Code")
        return(mushroom)
    })

    output$prediction <- renderPrint({
        req(values$prediction)
        return (values$prediction)
    })
}
