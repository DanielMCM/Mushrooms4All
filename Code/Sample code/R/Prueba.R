library(randomForest)
library(MASS)
library(h2o)
library(caret)
library(filesets)

m1 <- read.csv("mushrooms.csv")
m2 <- read.csv("mushrooms_v2 (prob 0.05).csv")

dummy <- caret::dummyVars("~ .", data = m2)
m3 <- data.frame(predict(dummy, newdata = m2))
m3$class.p <- NULL
write.csv(m3, file = "dummy.csv")
#####################################
########        RF        ###########
#####################################

m2 <- read.csv("mushrooms_v2 (prob 0.05).csv")
rf2 = randomForest(class ~ ., data = m2)
rf2
saveRDS(rf2, "RandomForest.RData")
rf3 <- readRDS("RandomForest.RData")
rf3
cv <- rfcv(m2[, 2:23], m2[, 1], cv.fold = 5)
predict(rf3, m2)
cv$error.cv

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

pred <- h2o.predict(aml@leader, train[1,])

aml@leader

saveRDS(aml, "AutomatedMLH2O.RData")

data <- readRDS("AutomatedMLH2O.RData")

print(lb, n = nrow(lb))

#################################
######## GRAPHS #################
#################################

p = ggplot(m2, aes(x = bruises,
                    y = odor,
                    color = class))

p + geom_jitter(alpha = 0.3) +
    scale_color_manual(breaks = c('edible', 'p'),
                     values = c('darkgreen', 'red'))



a = list(list("s", "f", "g", "t", "p", "f", "d", "n", "k", "e", "e", "s", "s", "c", "c", "p", "w", "t", "p", "k", "n", "u"))

b <- as.data.frame(a)

c <- list(as.list(b[1,]))

library(party)

cf1 <- cforest(class ~ ., data = m2,
               control = cforest_unbiased(mtry = 2, ntree = 50))

varimp(cf1)

library(varImp)
varimpAUC(cf1)

library(earth)
marsModel <- earth(class ~ ., data = m2) # build model
ev <- evimp(marsModel) # estimate variable importance
ev

plot(ev)

m4 <- m2
m4$gill.color <- NULL
rf2 = randomForest(class ~ ., data = m2)
rf2

rf3 = randomForest(class ~ ., data = m4)
rf3


############################

library(caret)

fitControl <- trainControl(## 10-fold CV
                           method = "repeatedcv",
                           number = 10,
## repeated ten times
                           repeats = 10)

gbmFit1 <- train(class ~ ., data = m2,
                 method = "gbm",
                 trControl = fitControl,
## This last option is actually one
## for gbm() that passes through
                 verbose = FALSE)

gbmImp <- varImp(gbmFit1, scale = FALSE)
gbmImp

############################
library(rpart)
treemodel <- readRDS("DecisionTree.RDATA")
m_barra <- read.csv("mushrooms_v2 (prob 0.05)_barra.csv")
colnames(m_barra) <- gsub("\\.", "_", colnames(m_barra))
m_barra$class = sapply(m_barra$class, function(x) { ifelse(x == 'e', 'edible', 'poisonous') })


#tree2 <- rpart(formula = class ~ ., data = m2, control = rpart.control(cp = 5e-04))

printcp(treemodel)

#printcp(teemodel)
plotcp(tree2)

tree_pred = predict(treemodel, m_barra, type = 'class')
tree_pred
print(table(tree_pred, m_barra$class))
accuracy_preprun = mean(tree_pred == m_barra$class)

a <- predict(tree.pruned, type = "class")

#Postpruning
# Prune the hr_base_model based on the optimal cp value
hr_model_pruned <- prune(treemodel, cp = 0.0017)
# Compute the accuracy of the pruned tree
test <- predict(hr_model_pruned, m_barra, type = "class")
accuracy_preprun = mean(tree_pred == m_barra$class)
accuracy_postprun <- mean(test == m_barra$class)
data.frame(base_accuracy, accuracy_preprun, accuracy_postprun)

printcp(hr_model_pruned)

library(rpart.plot)
library(RColorBrewer)
library(rattle)

fancyRpartPlot(treemodel)