import ballerina/io;
import ballerina/http;

http:Client clientEP = check new ("https://postman-echo.com/post");

service /svc on new http:Listener(8090) {
    resource function get path(http:Caller caller, http:Request req) {
        if (isAuthenticated(caller, req)) {
            var clientResponse = clientEP->post("/", "");
            if (clientResponse is http:Response) {
                io:println(clientResponse.getTextPayload());
            } else {
                io:println("error while calling the endpoint. " + clientResponse.message());
            }
            checkpanic caller->respond("Success");
        }
        checkpanic caller->respond("Unsuccessful");
    }
}

http:JwtValidatorConfig jwtValidatorConfig = {
    issuer: "https://localhost:9443/oauth2/token",
    audience: "vEwzbcasJVQm1jVYHUHCjhxZ4tYa",
    signatureConfig: {
        jwksConfig: {
            url: "http://localhost:9095/oauth2/token",
            cacheConfig: {
                capacity: 500,
                evictionFactor: 0.4,
                defaultMaxAge: 300,
                cleanupInterval: 420
            }
        }
    }
};

http:ListenerJwtAuthHandler jwtAuthHandler = new (jwtValidatorConfig);

function isAuthenticated(http:Caller caller, http:Request request) returns boolean {
    var authn = jwtAuthHandler.authenticate(request);
    if (authn is http:Unauthorized) {
        return false;
    } else {
        return true;            
    }
}