import ballerina/http;
import ballerina/log;

http:Client http_1_1_default = new("http://localhost:9090");

http:Client http_1_1_auto = new("http://localhost:9090",
                                 config = { http1Settings : { keepAlive: http:KEEPALIVE_AUTO }});

http:Client http_1_1_always = new("http://localhost:9090",
                                 config = { http1Settings : { keepAlive: http:KEEPALIVE_ALWAYS }});

http:Client http_1_1_never = new("http://localhost:9090",
                                 config = { http1Settings : { keepAlive: http:KEEPALIVE_NEVER }});

http:Client http_1_0_default = new("http://localhost:9090", config = { httpVersion: "1.0" } ); 

http:Client http_1_0_auto = new("http://localhost:9090",
                                 config = { httpVersion: "1.0", http1Settings : { keepAlive: http:KEEPALIVE_AUTO }});

http:Client http_1_0_always = new("http://localhost:9090",
                                 config = { httpVersion: "1.0", http1Settings : { keepAlive: http:KEEPALIVE_ALWAYS }});

http:Client http_1_0_never = new("http://localhost:9090",
                                 config = { httpVersion: "1.0", http1Settings : { keepAlive: http:KEEPALIVE_NEVER }});

service keepAliveTest on new http:Listener(9092) {

    @http:ResourceConfig {
        path: "/h1_1"
    }
    resource function h1_1_test(http:Caller caller, http:Request req) {
        var res1 = checkpanic http_1_1_default->post("/echo/", { "name": "Ballerina" });
        var res2 = checkpanic http_1_1_auto->post("/echo/", { "name": "Ballerina" }); 
        var res3 = checkpanic http_1_1_always->post("/echo/", { "name": "Ballerina" });
        var res4 = checkpanic http_1_1_never->post("/echo/", { "name": "Ballerina" });

        http:Response[] resArr = [res1, res2, res3, res4];
        string result = processResponse("http_1_1", resArr);
        checkpanic caller->respond(untaint result);
    }

    @http:ResourceConfig {
        path: "/h1_0"
    }
    resource function h1_0_test(http:Caller caller, http:Request req) {
        var res1 = checkpanic http_1_0_default->post("/echo/", { "name": "Ballerina" });
        var res2 = checkpanic http_1_0_auto->post("/echo/", { "name": "Ballerina" }); 
        var res3 = checkpanic http_1_0_always->post("/echo/", { "name": "Ballerina" });
        var res4 = checkpanic http_1_0_never->post("/echo/", { "name": "Ballerina" });

        http:Response[] resArr = [res1, res2, res3, res4];
        string result = processResponse("http_1_0", resArr);
        checkpanic caller->respond(untaint result);
    }
}

service echo on new http:Listener(9090) {
    @http:ResourceConfig {
        path: "/"
    }
    resource function echoResource(http:Caller caller, http:Request req) {
        string value;
        if (req.hasHeader("connection")) {
            value = req.getHeader("connection");
            if (req.hasHeader("keep-alive")) {
                value += "--" + req.getHeader("keep-alive");
            }
        } else {
            value = "No connection header found";
        }
        checkpanic caller->respond(value);
    }
}

function processResponse(string protocol, http:Response[] responseArr) returns string {
    string returnValue = protocol;
    foreach var response in responseArr {
       string payload = checkpanic response.getTextPayload();
       returnValue +=  "--" + payload;
    }

    return returnValue;
}
