//
//  DataExtension.swift
//  CosmoCuisine-Client
//
//  Created by Tyler Eaden on 12/16/24.
//

import Foundation

// Helps with creating multipart/form-data requests in NetworkingModel
extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
