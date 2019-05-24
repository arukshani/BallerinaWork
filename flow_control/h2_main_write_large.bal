import ballerina/http;
import ballerina/io;

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
    // timeoutMillis : 100000000
};

http:Client nettyEP = new("https://localhost:9091", config = sslClientConf);

public function main() {
    http:Request req = new;
    req.setFileAsPayload("2GB.zip");
    var clientResponse = nettyEP->post("/saveIncomingData", req);
    if (clientResponse is http:Response) {
        io:println(clientResponse.statusCode);
        var payload = clientResponse.getTextPayload();
        if (payload is string) {
            io:println("return val:" + payload);
        }
    } else {
        io:println(<string> clientResponse.detail().message);
    }
}
