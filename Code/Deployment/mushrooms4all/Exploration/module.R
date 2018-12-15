###################################################
##########        Exploration Module       ########
###################################################

exploration_path <- "Exploration/"

# UI

exploration_ui <- function(id) {
    ns <- NS(id)
    tabPanel(
        title = "Explore your mushrooms",
        br(),
        fluidRow(
            box(class = "exploration-picker-column text-right", title = h3("Choose a CSV file"), fileInput(ns("input_csv_file"), NULL, accept = c("text/csv", "text/comma-separated-values,text/plain", ".csv"))),
            box(title = h3("Select features to compare"), selectizeInput(ns('columns'), NULL, choices = mushrooms_columns, multiple = TRUE, options = list(placeholder = 'Choose the features to compare')))),
        fluidRow(
            box(width = 12,
                title = h4("Sankei diagram"),
                plotlyOutput(ns('plot.sankei')))))
}

# Server

exploration_server <- function(input, output, session) {

    observe({
        req(input$input_csv_file) # Only when file is chosen

        # Read data
        data <- read.table(input$input_csv_file$datapath, header = TRUE, sep = ",", na.strings = "NONE", quote = "")
        data <- data[complete.cases(data),]
      
        # Save dataset
        values$mushrooms <<- data
        values$mushrooms_columns <<- colnames(data)
        mushrooms_columns <<- colnames(data)

        # Enable run model
        shinyjs::enable("button_run_model")
    })

    observe({
        req(values$mushrooms_columns)
        updateSelectizeInput(session, 'columns', choices = values$mushrooms_columns, selected = NULL, server = FALSE)
    })

    output$plot.sankei <- renderPlotly({
        req(input$columns)
        req(values$mushrooms)
        req(values$mushrooms_columns)

        if (length(input$columns) < 2) {
            return()
        }

        mushrooms <- values$mushrooms

        nodes <- c()
        colors <- c()
        sources <- c()
        targets <- c()
        values <- c()

        for (i in 1:(length(input$columns) - 1)) {
            left_column <- input$columns[i] # left column
            left_values <- as.character(unique(mushrooms[[left_column]])) # left values

            nodes <- c(nodes, left_values)
            offset <- length(colors)
            colors[(offset + 1):(offset + length(left_values))] <- i

            for (j in (i + 1):length(input$columns)) {

                right_column <- input$columns[j] # right column
                right_values <- as.character(unique(mushrooms[[right_column]])) # right values

                for (k in 1:length(left_values)) {

                    left_node <- as.character(left_values[k])

                    for (l in 1:length(right_values)) {

                        right_node <- as.character(right_values[l])

                        mushrooms_subset <- mushrooms[, c(left_column, right_column)]
                        mushrooms_subset <- mushrooms_subset[mushrooms_subset[,1] == left_node & mushrooms_subset[,2] == right_node,]
                       
                        weight <- nrow(mushrooms_subset)

                        sources <- c(sources, left_node)
                        targets <- c(targets, right_node)
                        values <- c(values, weight)
                    }
                }
            }
        }
        nodes <- c(nodes, right_values)
        offset <- length(colors)
        colors[(offset + 1):(offset + length(left_values))] <- length(input$columns)

        sources <- as.numeric(mapvalues(sources, nodes, c(1:length(nodes))))
        targets <- as.numeric(mapvalues(targets, nodes, c(1:length(nodes))))

        my_colors <- colorRampPalette(brewer.pal(9, "Set1"))(22)
        colors <- mapvalues(colors, c(1:length(input$columns)), my_colors[1:length(input$columns)])
        
        return(plot_ly(
                type = "sankey",
                orientation = "h",
                node = list(
                    label = nodes,
                    color = colors
                ),
                link = list(
                    source = sources,
                    target = targets,
                    value = values
                )))
    })

    observeEvent(input$button_run_model, {
        #values$navigateTo("Results")
        #values$state <<- "processing"
    })
}
