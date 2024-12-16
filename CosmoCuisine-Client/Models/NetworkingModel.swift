//
//  NetworkingModel.swift
//  CosmoCuisine-Client
//
//  Created by Tyler Eaden on 12/13/24.
//

import UIKit

// This model uses delegation to interact with the main controller
protocol ClientDelegate {
    func receiveResponse(code: Any, strData: Any)
}

enum RequestEnum: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
}

class NetworkingModel: NSObject, URLSessionDelegate{
    
    //MARK: Properties and Delegation
    private let operationQueue = OperationQueue()
    
    
    var server_ip = "10.32.1.151"   // Default ip acquired from ifconfig |grep "inet "
    var delegate: ClientDelegate?   // Create a delegate for using the protocol
    
    lazy var session = {
        let sessionConfig = URLSessionConfiguration.ephemeral
        
        sessionConfig.timeoutIntervalForRequest = 5.0
        sessionConfig.timeoutIntervalForResource = 8.0
        sessionConfig.httpMaximumConnectionsPerHost = 1
        
        let tmp = URLSession(configuration: sessionConfig,
            delegate: self,
            delegateQueue:self.operationQueue)
        
        return tmp
    }()
    
    //MARK: Setters and Getters
    func setServerIp(ip:String)->(Bool){
        // user is trying to set ip: make sure that it is valid ip address
        if matchIp(for:"((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\\.|$)){4}", in: ip){
            server_ip = ip
            // return success
            return true
        } else{
            return false
        }
    }
    
    
    // MARK: Main Functions
    // Post data without a label
        func sendData(modelName: String) {
            // create a custom HTTP POST request
            let baseURL = "http://\(server_ip):8000/predict"
            let postUrl = URL(string: "\(baseURL)")
            var request = URLRequest(url: postUrl!)
            request.httpMethod = "POST"

            // Generate a unique boundary string using UUID
            let boundary = "Boundary-\(UUID().uuidString)"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

            // Create the multipart/form-data body
            var body = Data()

            // Append wav_file field with the audio file
            let fileFieldName = "wav_file"
            let fileName = "recording.wav"
            let mimeType = "audio/wav"

            // Get the file URL for the recording.wav in the app's documents directory
            let fileManager = FileManager.default
            let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsDirectory.appendingPathComponent(fileName)

            // Check if the file exists
            guard fileManager.fileExists(atPath: fileURL.path) else {
                print("File does not exist at path: \(fileURL.path)")
                return
            }

            // Read the file data
            guard let fileData = try? Data(contentsOf: fileURL) else {
                print("Unable to read file data")
                return
            }

            // Append the file data to the body
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(fileFieldName)\"; filename=\"\(fileName)\"\r\n")
            body.append("Content-Type: \(mimeType)\r\n\r\n")
            body.append(fileData)
            body.append("\r\n")

            // Close the multipart/form-data body
            body.append("--\(boundary)--\r\n")

            // Set the body of the request
            request.httpBody = body

            // Create a URLSession data task
            let session = URLSession.shared
            let task = session.dataTask(with: request) { data, response, error in
                
                guard let delegate = self.delegate else {
                    print("No delegate assigned f")
                    return
                }
        
                if error != nil {
                    if let res = response{
                        delegate.receiveResponse(code: 500, strData: "No ML prediction received from server")
                    }
                }
                
                else if let httpResponse = response as? HTTPURLResponse {
                    let statusCode = httpResponse.statusCode
                    let jsonDictionary = self.convertDataToDictionary(with: data)
                    
                    // Get language label
                    if let pred = jsonDictionary["prediction"] {
                        delegate.receiveResponse(code: statusCode, strData: String(describing: pred))
                    } else {
                        delegate.receiveResponse(code: 500, strData: "No ML prediction received from server")
                    }
                }
            }

            // Start the task
            task.resume()
        }
        
    //MARK: Utility Functions
    private func matchIp(for regex:String, in text:String)->(Bool){
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
            if results.count > 0{return true}
            
        } catch _{
            return false
        }
        return false
    }
    
    private func convertDataToDictionary(with data:Data?)->[String:Any]{
        // convenience function for getting Dictionary from server data
        do { // try to parse JSON and deal with errors using do/catch block
            let jsonDictionary: [String:Any] =
                try JSONSerialization.jsonObject(with: data!,
                                                 options: JSONSerialization.ReadingOptions.mutableContainers) as! [String : Any]
            
            return jsonDictionary
            
        } catch {
            print("json error: \(error.localizedDescription)")
            if let strData = String(data:data!, encoding:String.Encoding(rawValue: String.Encoding.utf8.rawValue)){
                print("printing JSON received as string: "+strData)
            }
            return [String:Any]() // just return empty
        }
    }

}
