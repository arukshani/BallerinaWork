import ballerina/http;
import ballerina/io;
import ballerina/log;

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

// public function main() {
//     http:Request req = new;
//     req.setFileAsPayload("2GB.zip");
//     var clientResponse = nettyEP->post("/", req);
//     if (clientResponse is http:Response) {
//         io:println(clientResponse.statusCode);
//         var payload = clientResponse.getTextPayload();
//         if (payload is string) {
//             io:println(payload);
//         }
//     } else {
//         io:println(clientResponse.reason());
//     }
// }

public function main() {
    string dstPath = "./files/ballerinaCopy.zip";
    var clientResponse = nettyEP->get("/largeFile");
    if (clientResponse is http:Response) {
        io:println(clientResponse.statusCode);
        var srcCh = clientResponse.getByteChannel();
         if (srcCh is io:ReadableByteChannel) {
            io:WritableByteChannel dstCh = io:openWritableFile(dstPath);
            var result = copy(srcCh, dstCh);
            if (result is error) {
                log:printError("error occurred while performing copy ", err = result);
            } else {
                io:println("File copy completed. The copied file could be located in " +
                            dstPath);
            }
        }
    } else {
        io:println(<string> clientResponse.detail().message);
    }
}

function copy(io:ReadableByteChannel src,
              io:WritableByteChannel dst) returns error? {
    int readCount = 1;
    byte[] readContent;

    while (readCount > 0) {

        (byte[], int) result = check src.read(1000);
        (readContent, readCount) = result;

        var writeResult = check dst.write(readContent, 0);
    }
    return;
}

function close(io:ReadableByteChannel|io:WritableByteChannel ch) {
    abstract object {
        public function close() returns error?;
    } channelResult = ch;
    var cr = channelResult.close();
    if (cr is error) {
        log:printError("Error occured while closing the channel: ", err = cr);
    }
}
