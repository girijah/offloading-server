
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
        // fatal error launching one of the servers
        fatalError("\(error)")
    }
    response.completed()
}

routes.add(method: .post, uri: "/test") {
    request, response in
    
    var responsePayload: [String: Any] = [ "remote_says" : 0 ]
    
    if let param = request.param(name: "test") {
        if param == "hi" {
            responsePayload["remote_says"] = "hello from remote"
        print("The remote says: \(String(describing: responsePayload["remote_says"]))")
        }
    }
    
    do {
        try response.setBody(json: responsePayload)
    } catch {
        // fatal error launching one of the servers
        fatalError("\(error)")
    }
    response.completed()
}


routes.add(method: .post, uri: "/recognizeImage") {
    request, response in
    
    var responsePayload: [String: Any] = [ "recognizedImage" : "" ]
    
    if let sampleBufferInString = request.param(name: "bufferParameter") {
        
        do {
            // json string to json data
            let jsonData = try JSONSerialization.data(withJSONObject: sampleBufferInString, options: JSONSerialization.WritingOptions.prettyPrinted)
            
            print("JSON Data: " , jsonData)
            
            // json data to object
            let jsonObject = try! JSONSerialization.jsonObject(with: jsonData, options: .allowFragments)
            let sampleBuffer: CMSampleBuffer = jsonObject as! CMSampleBuffer
            print("Buffer converted: ", sampleBuffer)
            
            // Image recognition
            guard let model = try? VNCoreMLModel(for: Resnet50().model) else { return }
            let request = VNCoreMLRequest(model: model) { (finishedRequest, error) in
                guard let results = finishedRequest.results as? [VNClassificationObservation] else { return }
                guard let Observation = results.first else { return }
                
                responsePayload["recognizedImage"] = Observation.identifier
                
                print("Recognized object is: \(String(describing: responsePayload["recognizedImage"])) ")
                
            }
            guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            
            // executes request
            try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
            
        } catch let error {
            print (error)
        }
        
    }
    
    do {
        try response.setBody(json: responsePayload)
    } catch {
        // fatal error launching one of the servers
        fatalError("\(error)")
    }
    response.completed()
}


routes.add(method: .get, uri: "/offload") {
    request, response in
    
    response.setBody(string: "Handler was called")
    
    for i in 0..<1000000 {
        print ("Execution of tasks!! ", i )
    }
    
    response.completed()
}


do {
    // Launch the HTTP server.
    try HTTPServer.launch(
        .server(name: "localhost", port: 8181, routes: routes))
} catch {
    // fatal error launching one of the servers
    fatalError("\(error)")
}
