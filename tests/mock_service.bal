import ballerina/http;

listener http:Listener azureOAuth2TokenProvider = new(9095);


service /oauth2 on azureOAuth2TokenProvider {

    resource function post token(http:Caller caller, http:Request req) {
        checkpanic caller->respond("sampletoken");
    }
}