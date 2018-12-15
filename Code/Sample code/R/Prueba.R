library(randomForest)
library(MASS)
library(h2o)
library(caret)

m1 <- read.csv("mushrooms.csv")
m2 <- read.csv("mushrooms_v2 (prob 0.05).csv")

dummy <- caret::dummyVars("~ .", data = m2)
m3 <- data.frame(predict(dummy, newdata = m2))
m3$class.p <- NULL
write.csv(m3, file = "dummy.csv")
#####################################
########        RF        ###########
#####################################

rf2 = randomForest(class ~ ., data = m2)
rf2
predict(rf2, m2)
saveRDS("rf2", "RandomForest.RData")

#####################################
########        h2o       ###########
#####################################

# Identify predictors and response

h2o.init()

train <- h2o.importFile("dummy.csv", header = TRUE)

y <- "class.e"
x <- setdiff(names(train), y)



# For binary classification, response should be a factor
train[, y] <- as.factor(train[, y])
#test[, y] <- as.factor(m1[, y])

aml <- h2o.automl(x = x, y = y,
                  training_frame =  train,
                  max_models = 20,
                  seed = 1)


lb <- aml@leaderboard
print(lb, n = nrow(lb)) # Print all rows instead of default (6 rows)

aml@leader

pred <- h2o.predict(aml@leader, test)

saveRDS("aml", "AutomatedMLH2O.RData")


