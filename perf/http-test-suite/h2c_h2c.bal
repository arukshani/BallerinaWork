import ballerina/http;
import ballerina/log;

listener http:Listener passthroughListener = new(9090,
    config = {
        httpVersion: "2.0"
    }
);

http:Client passthroughClient = new("http://169.254.107.89:8688",
    config = {
        httpVersion: "2.0"
    }
);

@http:ServiceConfig { basePath: "/passthrough" }
service passthroughService on passthroughListener {

    @http:ResourceConfig { path: "/" }
    resource function passthrough(http:Caller outboundEP, http:Request clientRequest) {
        var response = passthroughClient->forward("/hello/sayHello", clientRequest);
        if (response is http:Response) {
            _ = outboundEP->respond(response);
        } else {
            log:printError("Error at passthrough service", err = response);
            http:Response res = new;
            res.statusCode = http:INTERNAL_SERVER_ERROR_500;
            json errMsg = { message: <string>response.detail().message };
            res.setPayload(errMsg);
            _ = outboundEP->respond(res);
        }
    }
}
