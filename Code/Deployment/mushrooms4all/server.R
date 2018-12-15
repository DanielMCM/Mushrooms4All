###################################################
##########           Server        ################
###################################################

library(shiny)
library(utils)
directory <- getSrcDirectory(function(dummy) { dummy })
setwd(directory)

source("libraries.R", local = TRUE)
source("sources.R", local = TRUE)

shinyServer(function(input, output) {

    output$title <- renderPrint({
        "Este es el titulo"
    })

    # Save global session
    #values$globalSession <- session

    ## Call modules
    #callModule(checking_server, "Checking")
    #callModule(exploration_server, "Exploration")
    #callModule(api_server, "API")
    #callModule(team_server, "Team")
})