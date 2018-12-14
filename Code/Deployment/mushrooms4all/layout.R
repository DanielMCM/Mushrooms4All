###################################################
##########           Layout        ################
###################################################

# Header

header <- function(id) {
    ns <- NS(id)
    div(
        h1("Mushrooms4all", class = "title"),
        hr(class = "title-underline")
    )
}

# Content

content <- function(id) {
    ns <- NS(id)
    tabsetPanel(id = "tabs", checking_ui("Checking"), exploration_ui("Exploration"), api_ui("API"), team_ui("Team"), type = "pills")
}