###################################################
##########           Server        ################
###################################################

source("libraries.R")
source("sources.R")

server <- function(input, output, session) {

    # Save global session
    values$globalSession <- session

    # Call modules
    callModule(checking_server, "Checking")
    callModule(exploration_server, "Exploration")
    callModule(api_server, "API")
    callModule(team_server, "Team")
}