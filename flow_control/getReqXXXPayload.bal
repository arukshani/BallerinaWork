import ballerina/http;
import ballerina/io;

http:ServiceEndpointConfiguration serviceConfig = {
    httpVersion: "2.0",
    secureSocket: {
        keyStore: {
            path: "ballerinaKeystore.p12",
            password: "ballerina"
        }
    }
};

@http:ServiceConfig { basePath: "/test" }
service passthroughService on new http:Listener(9090, config = serviceConfig) {

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/"
    }
    resource function passthrough(http:Caller caller, http:Request clientRequest) {
        var payload = clientRequest.getJsonPayload();
        if (payload is json) {
            io:println(payload);
            var ee = caller->respond(untaint payload);
        } else {
            io:println("Error reading request payload");
            var ee = caller->respond("Error reading request payload");
        }
    }
}
