###################################################
##########           Connection    ################
###################################################

api_keys.boosted <- "stBIvZeMi7nCKQyDTKx2rC3CaCWzmyKgE7o0qh6jhcE5rseLXxFhuqZd7hSPoI40KKV+80pIc/GtsF+Wqkzs7A=="
urls.boosted <- "https://europewest.services.azureml.net/workspaces/9f6cbb787ae24af8bd2cb1fe82f331a7/services/2916893a381f4fdcaeb283d15618340b/execute?api-version=2.0&details=true"

azureml_predict_boosted <- function(input) {
    return(azureml_predict(api_keys.boosted, urls.boosted, input))
}

azureml_predict <- function(api_key, url, input) {

    # Accept SSL certificates issued by public Certificate Authorities
    options(RCurlOptions = list(cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl")))

    h <- basicTextGatherer()
    hdr <- basicHeaderGatherer()

    # request
    req <- list(
            Inputs = list("input1" = input),
            GlobalParameters = setNames(fromJSON('{}'), character(0)))

    body = enc2utf8(toJSON(req))
    api_key = api_keys.boosted # Replace this with the API key for the web service
    authz_hdr = paste('Bearer', api_key, sep = ' ')

    h$reset()
    curlPerform(url = urls.boosted,
            httpheader = c('Content-Type' = "application/json", 'Authorization' = authz_hdr),
            postfields = body,
            writefunction = h$update,
            headerfunction = hdr$update,
            verbose = TRUE)

    headers = hdr$value()
    httpStatus = headers["status"]
    if (httpStatus >= 400) {
        print(paste("The request failed with status code:", httpStatus, sep = " "))
        # Print the headers - they include the requert ID and the timestamp, which are useful for debugging the failure
        print(headers)
    }

    print("Result:")
    result <- fromJSON(h$value())
    return(result)
}