###################################################
##########           Server        ################
###################################################

library(shiny)
library(utils)
directory <- getSrcDirectory(function(dummy) { dummy })
setwd(directory)

source("libraries.R", local = TRUE, encoding = "UTF-8")
#source("sources.R", local = TRUE, encoding = "UTF-8")

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