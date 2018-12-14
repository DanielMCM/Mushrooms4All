###################################################
##########          API Module             ########
###################################################

api_path <- "API/"

# UI

api_ui <- function(id) {
    ns <- NS(id)
    tabPanel(
        title = "API"
    )
}

# Server

api_server <- function(input, output, session) {

}
