###################################################
##########           UI            ################
###################################################

library(shiny)
library(utils)
directory <- getSrcDirectory(function(dummy) { dummy })
setwd(directory)

source("libraries.R", local = TRUE)
source("sources.R", local = TRUE)

shinyUI(fluidPage(
    fluidRow(class = "main",
        div(class = "content-wrapper",
            verbatimTextOutput("title")
        )
    )
))