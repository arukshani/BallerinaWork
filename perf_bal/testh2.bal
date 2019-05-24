import ballerina/http;
import ballerina/log;

http:ServiceEndpointConfiguration serviceConfig = {
    httpVersion: "2.0",
    secureSocket: {
        keyStore: {
            path: "/home/rukshani/BallerinaWork/PERF_BAL/ballerinaKeystore.p12",
            password: "ballerina"
        }
    }
};

@http:ServiceConfig { basePath: "/service" }
service passthroughService on new http:Listener(8688, config = serviceConfig) {

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/EchoService"
    }
    resource function passthrough(http:Caller caller, http:Request clientRequest) {
        var payload = clientRequest.getBinaryPayload();
        if (payload is byte[]) {
            var ee = caller->respond(untaint payload);
        } else {
            var ee = caller->respond("error");
        }
    }
}
