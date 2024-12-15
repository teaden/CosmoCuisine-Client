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
    // Get shortened list of all records matching product_name in database
    func getMatchingProducts(product_name: String) {
        // create a custom HTTP GET request
        let baseURL = "http://\(server_ip):8000/data/\(product_name)"
        let getUrl = URL(string: "\(baseURL)")
        var request = URLRequest(url: getUrl!)
        
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let getTask : URLSessionDataTask = self.session.dataTask(with: request,
                        completionHandler:{(data, response, error) in
                        
            if error != nil {
                if let res = response{
                    print("Response:\n", res)
                }
            }
            
            else if let httpResponse = response as? HTTPURLResponse {
                if let delegate = self.delegate {
                    let statusCode = httpResponse.statusCode
                    let jsonDictionary = self.convertDataToDictionary(with: data)
                    if let count = jsonDictionary["count"] {
                        delegate.receiveResponse(code: statusCode, strData: "\(count) records")
                    }
                }
            }
        })
        
        getTask.resume() // start the task
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
