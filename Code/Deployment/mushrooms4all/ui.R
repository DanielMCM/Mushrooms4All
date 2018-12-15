###################################################
##########           UI            ################
###################################################

library(shiny)
library(utils)
directory <- getSrcDirectory(function(dummy) { dummy })
setwd(directory)

source("libraries.R", local = TRUE, encoding = "UTF-8")
#source("sources.R", local = TRUE, encoding = "UTF-8")

shinyUI(fluidPage(
    fluidRow(class = "main",
        div(class = "content-wrapper",
            verbatimTextOutput("title")
        )
    )
))