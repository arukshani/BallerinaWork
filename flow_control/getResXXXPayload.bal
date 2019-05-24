import ballerina/http;
import ballerina/log;
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

http:ClientEndpointConfig sslClientConf = {
    httpVersion: "2.0",
    secureSocket: {
        trustStore: {
            path: "ballerinaKeystore.p12",
            password: "ballerina"
        },
        verifyHostname: false
    },
    poolConfig : {maxActiveStreamsPerConnection : 50}
};

http:Client nettyEP = new("https://localhost:9091", config = sslClientConf);

@http:ServiceConfig { basePath: "/test" }
service passthroughService on new http:Listener(9090, config = serviceConfig) {

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/"
    }
    resource function passthrough(http:Caller caller, http:Request clientRequest) {

        var response = nettyEP->get("/largeFile");

        if (response is http:Response) {
            var payload = response.getJsonPayload();
            if(payload is json) {
                io:println(payload);
                var ee = caller->respond(untaint payload);
            } else {
                log:printError("Error retrieving response payload");
                var ee = caller->respond("Error retrieving response payload");
            }
        } else {
            log:printError("Error at ", err = response);
            var ee = caller->respond("Error in inbound response");
        }
    }
}
