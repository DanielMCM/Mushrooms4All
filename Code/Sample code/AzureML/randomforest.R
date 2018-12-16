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

m2 <- read.csv("../../../Sample_Data/Raw/mushrooms_v2 (prob 0.05).csv")
#column_names <- c("class", "cap-shape", "cap-surface", "cap-color", "bruises", "odor", "gill-attachment", "gill-spacing", "gill-size", "gill-color", "stalk-shape", "stalk-root", "stalk-surface-above-ring", "stalk-surface-below-ring", "stalk-color-above-ring", "stalk-color-below-ring", "veil-type", "veil-color", "ring-number", "ring-type", "spore-print-color", "population", "habitat")
column_names <- gsub("-", ".", colnames(m2))
colnames(m2) <- column_names

for (name in column_names) {
    m2[[name]] <- factor(m2[[name]], levels = levels(m2[[name]]))
}

# Split the datasets

features_to_select <- column_names

# Select sample size
smp_size <- floor(0.75 * nrow(m2))

## set the seed to make your partition reproducible
set.seed(123)
train_ind <- sample(seq_len(nrow(m2)), size = smp_size)

train <- head(m2, n = length(train_ind))
test <- tail(m2, n = count(m2) - length(train_ind))

#for (name in features_to_select) {
    #levels(test[[name]]) <- levels(train[[name]])
#}

# Train the model

model.rf <- randomForest(class ~ ., data = m2)

# (Optional) Save the model as RDATA
save(model.rf, file = "RandomForest.RData")
rm(model.rf)
load("RandomForest.RData")

# Predict function to deploy

predict_mushrooms <- function(new_mushrooms) {
    library(randomForest)
    predictions <- predict(model.rf, new_mushrooms)
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