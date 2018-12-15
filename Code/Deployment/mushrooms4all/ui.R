###################################################
##########           UI            ################
###################################################

# Set current path as working directory (used to load other files easily)

library(utils)
directory <- getSrcDirectory(function(dummy) { dummy })
setwd(directory)

# Load libraries and other files

source("libraries.R", local = TRUE, encoding = "UTF-8")
source("sources.R", local = TRUE, encoding = "UTF-8")

# Load shiny ui

shinyUI(fluidPage(
    shinyjs::useShinyjs(debug = TRUE),
    theme = shinytheme("journal"),
    fluidRow(class = "main",
        div(class = "content-wrapper",
            header("Header"),
            content("Content")
        )
    ),
    tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")),
    tags$head(tags$link(rel = "stylesheet", href = "https://fonts.googleapis.com/css?family=Dancing+Script:400,700"))
))