// Copyright (c) 2019, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.package http2;

import ballerina/http;
import ballerina/log;

listener http:Listener ep1 = new(9097, config = { httpVersion: "2.0" });
listener http:Listener ep2 = new(9098, config = { httpVersion: "2.0" });

http:Client h1Client = new("http://localhost:9098", config = { httpVersion: "1.1", http2Settings: {
        http2PriorKnowledge: false }, poolConfig: {}, cache : {enabled:false} });

//  http:Client h2WithPriorKnowledge = new("http://localhost:9098", config = { httpVersion: "2.0", http2Settings: {
//         http2PriorKnowledge: true }, poolConfig: {} ,  cache : {enabled:false}});

// http:Client h2WithoutPriorKnowledge = new("http://localhost:9098", config = { httpVersion: "2.0", http2Settings: {
//         http2PriorKnowledge: false }, poolConfig: {}, cache : {enabled:false} });

@http:ServiceConfig {
    basePath: "/priorKnowledge"
}
service priorKnowledgeTest on ep1 {

    // @http:ResourceConfig {
    //     methods: ["GET"],
    //     path: "/on"
    // }
    // resource function priorOn(http:Caller caller, http:Request req) {
       
    //     var response = h2WithPriorKnowledge->post("/backend", "Prior knowledge is enabled");
    //     if (response is http:Response) {
    //         checkpanic caller->respond(untaint response);
    //     } else {
    //         checkpanic caller->respond("Error in client post with prior knowledge on");
    //     }
    // }

    // @http:ResourceConfig {
    //     methods: ["GET"],
    //     path: "/off"
    // }
    // resource function priorOff(http:Caller caller, http:Request req) {


    //     var response = h2WithoutPriorKnowledge->post("/backend", "Prior knowledge is disabled");
    //     if (response is http:Response) {
    //         checkpanic caller->respond(untaint response);
    //     } else {
    //         checkpanic caller->respond("Error in client post with prior knowledge off");
    //     }
    //     // checkpanic caller->respond("Error in client post with prior knowledge off");
    // }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/one"
    }
    resource function h1Cli(http:Caller caller, http:Request req) {


        var response = h1Client->post("/backend", "HTTP/1.1 request");
        if (response is http:Response) {
            checkpanic caller->respond(untaint response);
        } else {
            checkpanic caller->respond("Error in client post with prior knowledge off");
        }
        // checkpanic caller->respond("Error in client post with prior knowledge off");
    }
}

@http:ServiceConfig {
    basePath: "/backend"
}
service testBackEnd on ep2 {

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/"
    }
    resource function test(http:Caller caller, http:Request req) {
        string outboundResponse = "";
        if (req.hasHeader("connection") && req.hasHeader("upgrade")) {
            string[] connHeaders = req.getHeaders("connection");
            outboundResponse = connHeaders[1];
            outboundResponse = outboundResponse + "--" + req.getHeader("upgrade");
        } else {
            outboundResponse = "Connection and upgrade headers are not present";
        }

        log:printInfo(req.httpVersion);

        outboundResponse = outboundResponse + "--" + checkpanic req.getTextPayload() + req.httpVersion;
        checkpanic caller->respond(untaint outboundResponse);
    }
}
