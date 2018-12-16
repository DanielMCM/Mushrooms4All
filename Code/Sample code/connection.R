#####################################
########     Connection   ###########
#####################################

library("RCurl")
library("rjson")

# Accept SSL certificates issued by public Certificate Authorities
options(RCurlOptions = list(cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl")))

h = basicTextGatherer()
hdr = basicHeaderGatherer()

req = list(
        Inputs = list(
            "input1" = list(
                "ColumnNames" = list("cap.shape", "cap.surface", "cap.color", "bruises", "odor", "gill.attachment", "gill.spacing", "gill.size", "gill.color", "stalk.shape", "stalk.root", "stalk.surface.above.ring", "stalk.surface.below.ring", "stalk.color.above.ring", "stalk.color.below.ring", "veil.type", "veil.color", "ring.number", "ring.type", "spore.print.color", "population", "habitat"),
                "Values" = list(list("s", "f", "g", "t", "p", "f", "d", "n", "k", "e", "e", "s", "s", "c", "c", "p", "w", "t", "p", "k", "n", "u"))
            )),
        GlobalParameters = setNames(fromJSON('{}'), character(0))
)

body = enc2utf8(toJSON(req))
api_key = "zRXXwb1H9pxvrXMXySoSwSVpLJZuxi7+Zs8hCDpSsCokrlWBtvCinNqyhIGT6VadGJsYG5uryFRD1sYq/Gwhew==" # Replace this with the API key for the web service
authz_hdr = paste('Bearer', api_key, sep = ' ')

h$reset()
curlPerform(url = "https://europewest.services.azureml.net/workspaces/9f6cbb787ae24af8bd2cb1fe82f331a7/services/018b3004306845c18e0af2c8bbfe32fb/execute?api-version=2.0&details=true",
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
result = h$value()
print(fromJSON(result))