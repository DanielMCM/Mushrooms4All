###################################################
##########           Server        ################
###################################################

# Set current path as working directory (used to load other files easily)

library(utils)
directory <- getSrcDirectory(function(dummy) { dummy })
setwd(directory)

# Load libraries and other files

source("libraries.R", local = TRUE, encoding = "UTF-8")
source("sources.R", local = TRUE, encoding = "UTF-8")

# Load shiny server

shinyServer(function(input, output, session) {

    # Save global session
    values$globalSession <- session

    ## Call modules
    callModule(checking_server, "Checking")
    callModule(exploration_server, "Exploration")
    callModule(api_server, "API")
    callModule(team_server, "Team")
})