# these are the required packages and some initial manipulation of the data
library(ggplot2)
library(e1071)
library(stringr)
library(rpart)
library(rattle)

mushroom = read.csv("../../../Sample_Data/Raw/mushrooms_v2 (prob 0.05).csv")
colnames(mushroom) = str_replace_all(colnames(mushroom), "\\.", "_")
mushroom$veil_type = NULL # remove veil_type because all are partial, unnecessary column
mushroom$class = sapply(mushroom$class, function(x) { ifelse(x == 'e', 'edible', 'poisonous') })

set.seed(40) # setting the seed so that we get reproducible results
mushroom[, 'train'] <- ifelse(runif(nrow(mushroom)) < 0.8, 1, 0)
#separate training and test sets
trainset <- mushroom[mushroom$train == 1,]
testset <- mushroom[mushroom$train == 0,]
#get column index of train flag
trainColNum <- grep('train', names(trainset))
#remove train flag column from train and test sets
trainset <- trainset[, - trainColNum]
testset <- testset[, - trainColNum]

#get column index of predicted variable in dataset
typeColNum <- grep('Class', names(mushroom))

# complexity factor set to .0005
tree = rpart(class ~ ., data = trainset, control = rpart.control(cp = .0005))

saveRDS(tree, file = "DecisionTree.RData")
rm(tree)
readRDS("DecisionTree.RData")

tree_pred = predict(tree, testset, type = 'class')
mean(tree_pred == testset$class) # percent of the test set that was correctly predicted, with this seed the model happens to predict with 100% accuracy

table(tree_pred, testset$class)

# no mushrooms were missclassified in the test set
tree_pred_full = predict(tree, mushroom, type = 'class')
mean(tree_pred_full == mushroom$class) # percent of full data set that was correctly predicted

table(tree_pred_full, mushroom$class) # confusion matrix of the full data set and the model predictions