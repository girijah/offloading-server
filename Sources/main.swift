//
//  main.swift
//  PerfectTemplate
//
//  Created by Kyle Jessup on 2015-11-05.
//	Copyright (C) 2015 PerfectlySoft, Inc.
//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Perfect.org open source project
//
// Copyright (c) 2015 - 2016 PerfectlySoft Inc. and the Perfect project authors
// Licensed under Apache License v2.0
//
// See http://perfect.org/licensing.html for license information
//
//===----------------------------------------------------------------------===//
//

//import PerfectHTTP
//import PerfectHTTPServer
//
//// An example request handler.
//// This 'handler' function can be referenced directly in the configuration below.
//func handler(request: HTTPRequest, response: HTTPResponse) {
//    // Respond with a simple message.
//    response.setHeader(.contentType, value: "text/html")
//    response.appendBody(string: "<html><title>Hello, world!</title><body>Hello, world!</body></html>")
//    // Ensure that response.completed() is called when your processing is done.
//    response.completed()
//}
//
//// Configuration data for an example server.
//// This example configuration shows how to launch a server
//// using a configuration dictionary.
//
//
//let confData = [
//    "servers": [
//        // Configuration data for one server which:
//        //    * Serves the hello world message at <host>:<port>/
//        //    * Serves static files out of the "./webroot"
//        //        directory (which must be located in the current working directory).
//        //    * Performs content compression on outgoing data when appropriate.
//        [
//            "name":"localhost",
//            "port":8181,
//            "routes":[
//                ["method":"get", "uri":"/", "handler":handler],
//                ["method":"get", "uri":"/**", "handler":PerfectHTTPServer.HTTPHandler.staticFiles,
//                 "documentRoot":"./webroot",
//                 "allowResponseFilters":true]
//            ],
//            "filters":[
//                [
//                "type":"response",
//                "priority":"high",
//                "name":PerfectHTTPServer.HTTPFilter.contentCompression,
//                ]
//            ]
//        ]
//    ]
//]
//
//do {
//    // Launch the servers based on the configuration data.
//    try HTTPServer.launch(configurationData: confData)
//} catch {
//    fatalError("\(error)") // fatal error launching one of the servers
//}


import PerfectHTTP
import PerfectHTTPServer
import Vision
import CoreMedia

// Register your own routes and handlers

var routes = Routes()

routes.add(method: .get, uri: "/") {
    request, response in
    response.setHeader(.contentType, value: "text/html")
    response.appendBody(string: "<html><title>Hello, world!</title><body>Hello, world!</body></html>")
        .completed()
}

routes.add(method: .post, uri: "/add") {
    request, response in
    
    var responsePayload: [String: Any] = [ "sum" : 0 ]
    
    if let operandOne = request.param(name: "operandOne"), let operandTwo = request.param(name: "operandTwo") {
        if let lhs = Int(operandOne) , let rhs = Int(operandTwo) {
            
            responsePayload["sum"] = lhs + rhs
            print("The sum of the number is: \(String(describing: responsePayload["sum"])) ")
        }
    }
    
    do {
        try response.setBody(json: responsePayload)
    } catch {
        fatalError("\(error)") // fatal error launching one of the servers
    }
    response.completed()
}

routes.add(method: .post, uri: "/recognizeImage") {
    request, response in
    
    var responsePayload: [String: Any] = [ "recognizedImage" : 0 ]
    
    if let sampleBuffer = request.param(name: "bufferParameter") {
        
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else { return }
        let request = VNCoreMLRequest(model: model) { (finishedRequest, error) in
            guard let results = finishedRequest.results as? [VNClassificationObservation] else { return }
            guard let Observation = results.first else { return }
            
            responsePayload["recognizedImage"] = Observation.identifier
            print("Recognized object is: \(String(describing: responsePayload["recognizedImage"])) ")
        
        }
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer as! CMSampleBuffer) else { return }
        
        // executes request
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
        
    }
    
    do {
        try response.setBody(json: responsePayload)
    } catch {
        fatalError("\(error)") // fatal error launching one of the servers
    }
    response.completed()
}


routes.add(method: .get, uri: "/offload") {
    request, response in
    
    //var responsePayload: [String: Any] = [ "sum" : 0 ]
    response.setBody(string: "Handler was called")
    
        for i in 0..<1000000 {
            print ("Execution of tasks!! ", i )
        }

//    do {
//        try response.setBody(json: responsePayload)
//    } catch {
//        fatalError("\(error)") // fatal error launching one of the servers
//    }
    response.completed()
}


do {
    // Launch the HTTP server.
    try HTTPServer.launch(
        .server(name: "localhost", port: 8181, routes: routes))
} catch {
    fatalError("\(error)") // fatal error launching one of the servers
}
