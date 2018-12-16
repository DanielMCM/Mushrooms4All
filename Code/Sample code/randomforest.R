#####################################
########        RF        ###########
#####################################

library(randomForest)
library(MASS)
library(h2o)
library(caret)
library(e1071)
library(AzureML)
library(dplyr)

# Config

web_service_id <- "2c22fd4a00f611e9a96667a971359f92"
web_service_name <- "Score new mushrooms"
workspace_id <- "9f6cbb787ae24af8bd2cb1fe82f331a7"
auth_key <- "yxJRTwU8yTRFDGJs3GDbKplhJOXXeVIDY6934xtES4WvCH9s+kwsNXPvDWoNLV3+qL24p5RCftjGFkC1aOnNqw=="

# Datasets

m1 <- read.csv("mushrooms.csv")
m2 <- read.csv("mushrooms_v2 (prob 0.05).csv")

# Split the datasets

features_to_select <- c("class", "cap.shape", "cap.surface", "cap.color", "bruises", "odor", "gill.attachment", "gill.spacing", "gill.size", "gill.color", "stalk.shape", "stalk.root", "stalk.surface.above.ring", "stalk.surface.below.ring", "stalk.color.above.ring", "stalk.color.below.ring", "veil.type", "veil.color", "ring.number", "ring.type", "spore.print.color", "population", "habitat")

# Select sample size
smp_size <- floor(0.75 * nrow(m2))

## set the seed to make your partition reproducible
set.seed(123)
train_ind <- sample(seq_len(nrow(m2)), size = smp_size)

train <- m2[train_ind, features_to_select]
test <- m2[-train_ind, features_to_select]

levels(test$class) <- levels(train$class)
levels(test$cap.shape) <- levels(train$cap.shape)
levels(test$cap.color) <- levels(train$cap.color)
levels(test$cap.surface) <- levels(train$cap.surface)
levels(test$bruises) <- levels(train$bruises)
levels(test$odor) <- levels(train$odor)
levels(test$gill.attachment) <- levels(train$gill.attachment)
levels(test$gill.spacing) <- levels(train$gill.spacing)
levels(test$gill.size) <- levels(train$gill.size)
levels(test$gill.color) <- levels(train$gill.color)
levels(test$stalk.shape) <- levels(train$stalk.shape)
levels(test$stalk.root) <- levels(train$stalk.root)
levels(test$stalk.surface.above.ring) <- levels(train$stalk.surface.above.ring)
levels(test$stalk.surface.below.ring) <- levels(train$stalk.surface.below.ring)
levels(test$stalk.color.above.ring) <- levels(train$stalk.color.above.ring)
levels(test$stalk.color.below.ring) <- levels(train$stalk.color.below.ring)
levels(test$veil.type) <- levels(train$veil.type)
levels(test$veil.color) <- levels(train$veil.color)
levels(test$ring.number) <- levels(train$ring.number)
levels(test$ring.type) <- levels(train$ring.type)
levels(test$spore.print.color) <- levels(train$spore.print.color)
levels(test$population) <- levels(train$population)
levels(test$habitat) <- levels(train$habitat)

# Train the model

rf2 = randomForest(class ~ ., data = train)

#probabilities <- predict(rf2, m2, type = "response")
#saveRDS("rf2", "RandomForest.RData")

# Predict function to deploy

predict_mushrooms <- function(new_mushrooms) {
    library(randomForest)
    predictions <- predict(rf2, new_mushrooms)
    output <- data.frame(new_mushrooms, scored.labels = predictions)
    output
}

# Check predict function

head(predict_mushrooms(test[, -1]))

# Workspace

ws <- workspace(
    id = workspace_id,
    auth = auth_key,
    api_endpoint = "https://europewest.studio.azureml.net/")

# Publish web service

api <- publishWebService(
    ws,
    fun = predict_mushrooms,
      name = web_service_name,
      inputSchema = test[, -1],
    data.frame = TRUE
 )

# Update web service

getWebServices(ws) # Check web service id

api <- updateWebService(
  ws,
  fun = predict_mushrooms,
  inputSchema = test[, -1],
  serviceId = web_service_id
)

# Consume model

api <- getWebServices(ws, web_service_id)

consume(api, test[, -1])