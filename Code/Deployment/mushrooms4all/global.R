###################################################
##########           Global        ################
###################################################

library(stringr)

values <- reactiveValues()

# Code value dictionary -> Features

code_value_dictionary <- read.csv(file = "Data/code_value_dictionary.csv", sep = ",", header = TRUE)
code_value_dictionary$column <- as.factor(code_value_dictionary$column)
code_value_dictionary$name <- as.character(code_value_dictionary$name)
code_value_dictionary$code <- as.character(code_value_dictionary$code)

columns <- unique(code_value_dictionary$column)
columns <- columns[which(columns != "class")]

generate_key <- function(key, column) {
    return(str_c(key, " (", column, ")"))
}
generate_value <- function(column, value) {
    return(str_c(column, "::", value))
}

calculate_features <- function(ignore) {
    features <- list()
    for (column in columns) {
        pairs <- code_value_dictionary[code_value_dictionary$column == column, 2:3]
        options <- c()

        ignore_column <- column %in% gsub("+::.+", "", ignore)
        for (i in 1:nrow(pairs)) {
            key <- as.character(pairs[i, 1])
            value <- as.character(pairs[i, 2])
            key <- generate_key(key, column)
            value <- generate_value(column, value)

            if (ignore_column && !(value %in% ignore)) {
                next
            }

            options[[key]] <- value
        }
        features[[as.character(column)]] <- options
    }
    return(features)
}

random_selection <- function() {
    ignore <- c()
    for (column in columns) {
        codes <- code_value_dictionary[code_value_dictionary$column == column, 3]
        code <- sample(codes, 1)
        feature <- generate_value(column, code)
        ignore <- c(ignore, feature)
    }
    return(ignore)
}

features_selected <- c()
features <- calculate_features(c())

values$features_selected <- features_selected
values$features <- features

# Global session & navigation

values$globalSession <- NULL
values$navigateTo <- function(tabName) {
    showTab(inputId = "tabs", target = tabName, select = TRUE, session = values$globalSession)
}
