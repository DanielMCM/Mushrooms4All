###################################################
##########           UI            ################
###################################################

ui <- fluidPage(
    shinyjs::useShinyjs(debug = TRUE),
    theme = shinytheme("journal"),
    fluidRow(class = "main",
        div(class = "content-wrapper",
            header("Header"),
            content("Content")
        )
    ),
    tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")),
    tags$head(tags$link(rel = "stylesheet", href = "https://fonts.googleapis.com/css?family=Dancing+Script:400,700"))
)