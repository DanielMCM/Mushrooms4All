###################################################
##########           Libraries     ################
###################################################

load_libraries <- function(filepath) {

    # read file with packages

    i <- 1
    to_install <- list()
    con = file(filepath, "r") # open file connection
    while (TRUE) {
        line = readLines(con, n = 1)
        if (length(line) == 0) {
            break
        }
        to_install[[i]] <- line
        i <- i + 1
    }

    close(con) # close connection

    # install and load packages

    for (package in to_install) {
        if (!is.element(package, .packages(all.available = TRUE))) {
            install.packages(package)
        }
        library(package, character.only = TRUE)
    }
}

# load required libraries

load_libraries("requirements.txt")