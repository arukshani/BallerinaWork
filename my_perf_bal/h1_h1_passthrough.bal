import ballerina/http;
import ballerina/log;

http:ServiceEndpointConfiguration serviceConfig = {
    secureSocket: {
        keyStore: {
            path: "/home/rukshani/BallerinaWork/PERF_BAL/ballerinaKeystore.p12",
            password: "ballerina"
        }
    }
};

http:ClientEndpointConfig sslClientConf = {
    secureSocket: {
        trustStore: {
            path: "/home/rukshani/BallerinaWork/PERF_BAL/ballerinaKeystore.p12",
            password: "ballerina"
        },
        verifyHostname: false
    }
};

http:Client nettyEP = new("https://localhost:8688", config = sslClientConf);

@http:ServiceConfig { basePath: "/passthrough" }
service passthroughService on new http:Listener(9090, config = serviceConfig) {

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/"
    }
    resource function passthrough(http:Caller caller, http:Request clientRequest) {
        var response = nettyEP->forward("/service/EchoService", clientRequest);
        if (response is http:Response) {
            var result = caller->respond(response);
        } else {
            log:printError("Error at h1_h1_passthrough", err = response);
            http:Response res = new;
            res.statusCode = 500;
            res.setPayload(<string>response.detail().message);
            var result = caller->respond(res);
        }
    }
}
