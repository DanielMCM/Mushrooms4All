###################################################
##########        Exploration Module       ########
###################################################

exploration_path <- "Exploration/"

# UI

exploration_ui <- function(id) {
    ns <- NS(id)
    tabPanel(
        title = "Explore your mushrooms"
    )
}

# Server

exploration_server <- function(input, output, session) {

}
