###################################################
##########           Libraries     ################
###################################################

library(shiny)
library(shinyjs)
library(shinydashboard)
library(shinythemes)
library(stringr)
library(arules)
library(dplyr)
library(gridExtra)
library(grid)
library(dplyr)
library(ggplot2)
library(lattice)
library(arulesViz)
library(utils)
library(lubridate)
library(rlist)
library(lubridate)

###################################################
##########           Sources       ################
###################################################

source("layout.R")
source("global.R")

###################################################
##########           Server        ################
###################################################

server <- function(input, output, session) {

    # Save global session
    values$globalSession <- session

    # Call modules
    callModule(checking_server, "Checking")
    callModule(exploration_server, "Exploration")
    callModule(api_server, "API")
    callModule(team_server, "Team")
}