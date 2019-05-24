import ballerina/http;
import ballerina/log;
import ballerina/mime;
import ballerina/io;

// --- HTTP/1.1 Listener
//listener http:Listener listenerEP = new(9191);

// --- HTTP/1.1 Listener (SSL enabled)
//listener http:Listener listenerEP = new(9191,
// config = {
// secureSocket: {
// keyStore: {
// path: "${ballerina.home}/bre/security/ballerinaKeystore.p12",
// password: "ballerina"
// }
// }
// }
//);

// --- HTTP/2 Listener
listener http:Listener listenerEP = new(9191, config = { httpVersion: "2.0" });

// --- HTTP/2 Listener (SSL enabled)
//listener http:Listener listenerEP = new(9191,
// config = {
// httpVersion: "2.0",
// secureSocket: {
// keyStore: {
// path: "${ballerina.home}/bre/security/ballerinaKeystore.p12",
// password: "ballerina"
// }
// }
// }
//);

@http:ServiceConfig {
basePath: "/hello"
}
service hello on listenerEP {

@http:ResourceConfig {
methods: ["POST"],
path: "/sayHello"
}
resource function sayHello(http:Caller outboundEP, http:Request clientRequest) {
log:printInfo("before payload");
http:Response res = new;
var payload = clientRequest.getTextPayload();
log:printInfo("After payload");
if (payload is string) {
res.setTextPayload(untaint payload);
log:printInfo(payload);
} else {
log:printInfo(<string>payload.detail().message);
}

//var entity = clientRequest.getEntity();
//if (entity is mime:Entity) {
// res.setEntity(entity);
//} else {
// string errMsg = "An error occurred while retrieving the entity from the backend";
// log:printError(errMsg, err = entity);
// res.setPayload({ message: errMsg });
//}
//res.setHeader(http:CONTENT_TYPE, mime:APPLICATION_JSON);
checkpanic outboundEP->respond(res);
}
}