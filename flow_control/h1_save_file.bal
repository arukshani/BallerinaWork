import ballerina/http;
import ballerina/log;
import ballerina/io;
import ballerina/runtime;

http:ServiceEndpointConfiguration serviceConfig = {
    httpVersion: "1.1",
    secureSocket: {
        keyStore: {
            path: "ballerinaKeystore.p12",
            password: "ballerina"
        }
    }
};

@http:ServiceConfig { basePath: "/saveIncomingData" }
service passthroughService on new http:Listener(9091, config = serviceConfig) {
    @http:ResourceConfig {
        methods: ["POST"],
        path: "/"
    }
    resource function passthrough(http:Caller caller, http:Request clientRequest) returns error?{
        string dstPath = "./files/ballerinaCopy.zip";
        var srcCh = clientRequest.getByteChannel();
        // if (payload is io:ReadableByteChannel) {
        //     int readCount = 1;
        //     byte[] readContent;
        //     while (readCount > 0) {
        //         // runtime:sleep(100);
        //         (byte[], int) result = check payload.read(5000);
        //         (readContent, readCount) = result;
        //     }
        //     close(payload);
        // }

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
         
        var err = caller->respond("Hello!");
        return;
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
