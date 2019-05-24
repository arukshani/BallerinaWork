import ballerina/http;
import ballerina/log;
import ballerina/io;

http:ServiceEndpointConfiguration serviceConfig = {
    httpVersion: "1.1",
    secureSocket: {
        keyStore: {
            path: "ballerinaKeystore.p12",
            password: "ballerina"
        }
    }
    // timeoutMillis: 200000
};

@http:ServiceConfig { basePath: "/largeFile" }
service passthroughService on new http:Listener(9091, config = serviceConfig) {

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/"
    }
    resource function passthrough(http:Caller caller, http:Request clientRequest) {
        http:Response res = new;
        res.setFileAsPayload("2GB.zip");
        var ee = caller->respond(res);
    }
}
