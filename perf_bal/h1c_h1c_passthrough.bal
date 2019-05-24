
  
import ballerina/http;
import ballerina/log;

http:Client nettyEP = new("http://localhost:8688");

@http:ServiceConfig { basePath: "/passthrough" }
service passthroughService on new http:Listener(9090) {

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/"
    }
    resource function passthrough(http:Caller caller, http:Request clientRequest) {
        var response = nettyEP->forward("/service/EchoService", clientRequest);

        if (response is http:Response) {
            var result = caller->respond(response);
        } else {
            log:printError("Error at h1c_h1c_passthrough", err = response);
            http:Response res = new;
            res.statusCode = 500;
            res.setPayload(<string>response.detail().message);
            var result = caller->respond(res);
        }
    }
}
