###################################################
##########          API Module             ########
###################################################

api_path <- "API/"

# UI

api_ui <- function(id) {
    ns <- NS(id)
    tabPanel(
        title = "API",
        fluidRow(
            box(width = 12, title = h3("API")),
            box(width = 12, class = "well", "Consume our model to make predictions of unknown mushrooms through this publicly available API built on top of Azure Machine Learning studio. You can access the models from any environment able to make http requests."),
            br()),
        fluidRow(
            box(width = 12, title = h3("Security and access")),
            box(width = 12, class = "well", p("The model is located in the following endpoint through a POST request."),
                p(HTML("<b>https://europewest.services.azureml.net/workspaces/9f6cbb787ae24af8bd2cb1fe82f331a7/services/2916893a381f4fdcaeb283d15618340b/execute?api-version=2.0&details=true</b>")),
                br(),
                p("To be allowed to consume the model, the client has to include the following bearer token to the header of the request."),
                p(HTML("<b>stBIvZeMi7nCKQyDTKx2rC3CaCWzmyKgE7o0qh6jhcE5rseLXxFhuqZd7hSPoI40KKV+80pIc/GtsF+Wqkzs7A==</b>")))),
        fluidRow(
            box(width = 12, title = h3("Payload")),
            box(width = 12, class = "well", p("The data set of unknown mushrooms must be serialized into a JSON object with the following format, where the Values property contains one array of values per mushroom. In order the interpret the predictions, a response of the request with this format must be expected. The last two values in each array corresponds with the predicted class and the probability, respectively.")),
            box(width = 6, title = "Input", class = "well", '{
  "Inputs": {
    "input1": {
      "ColumnNames": [
        "cap-shape",
        "cap-surface",
        "cap-color",
        "bruises",
        "odor",
        "gill-attachment",
        "gill-spacing",
        "gill-size",
        "gill-color",
        "stalk-shape",
        "stalk-root",
        "stalk-surface-above-ring",
        "stalk-surface-below-ring",
        "stalk-color-above-ring",
        "stalk-color-below-ring",
        "veil-type",
        "veil-color",
        "ring-number",
        "ring-type",
        "spore-print-color",
        "population",
        "habitat"
      ],
      "Values": [
        [
          "value",
          "value",
          "value",
          "value",
          "value",
          "value",
          "value",
          "value",
          "value",
          "value",
          "value",
          "value",
          "value",
          "value",
          "value",
          "value",
          "value",
          "value",
          "value",
          "value",
          "value",
          "value"
        ]
      ]
    }
  },
  "GlobalParameters": {}
}
'),
            box(width = 6, title = "Output", class = "well", '{
  "Results": {
    "output1": {
      "type": "DataTable",
      "value": {
        "ColumnNames": [
          "cap-shape",
          "cap-surface",
          "cap-color",
          "bruises",
          "odor",
          "gill-attachment",
          "gill-spacing",
          "gill-size",
          "gill-color",
          "stalk-shape",
          "stalk-root",
          "stalk-surface-above-ring",
          "stalk-surface-below-ring",
          "stalk-color-above-ring",
          "stalk-color-below-ring",
          "veil-type",
          "veil-color",
          "ring-number",
          "ring-type",
          "spore-print-color",
          "population",
          "habitat",
          "Scored Labels",
          "Scored Probabilities"
        ],
        "ColumnTypes": [
          "String",
          "String",
          "String",
          "String",
          "String",
          "String",
          "String",
          "String",
          "String",
          "String",
          "String",
          "String",
          "String",
          "String",
          "String",
          "String",
          "String",
          "String",
          "String",
          "String",
          "String",
          "String",
          "String",
          "Numeric"
        ],
        "Values": [
          [
            "value",
            "value",
            "value",
            "value",
            "value",
            "value",
            "value",
            "value",
            "value",
            "value",
            "value",
            "value",
            "value",
            "value",
            "value",
            "value",
            "value",
            "value",
            "value",
            "value",
            "value",
            "value",
            "value",
            "0"
          ]
        ]
      }
    }
  }
}
')))
}

# Server

api_server <- function(input, output, session) {

}
