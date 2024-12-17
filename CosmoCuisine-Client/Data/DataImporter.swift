//
//  DataImporter.swift
//  CosmoCuisine-Client
//
//  Created by Tyler Eaden on 12/17/24.
//

import Foundation
import CoreData

protocol DataImporterDelegate: AnyObject {
    func dataImporter(progress: Float)
}

class DataImporter {
    
    private let repository: CoreDataRepository
    weak var delegate: DataImporterDelegate?
    
    init(repository: CoreDataRepository) {
        self.repository = repository
    }
    
    func importDataFromJSON() {
        do {
            try repository.deleteAllProducts()
        } catch {
            print("Error deleting existing products: \(error)")
        }
        
        guard let url = Bundle.main.url(forResource: "products", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Error loading JSON data")
            return
        }

        let decoder = JSONDecoder()
        
        do {
            // Decode the top-level structure into a dictionary
            let jsonResponse = try decoder.decode([String: [ProductData]].self, from: data)
            
            // Access the array of ProductData using the "products" key
            if let jsonData = jsonResponse["products"] {
                let totalItems = jsonData.count
                var currentItem = 0
                
                for itemData in jsonData {
                    do {
                        _ = try repository.insertProduct(from: itemData)
                    } catch {
                        print("Error inserting product: \(error)")
                    }
                    
                    currentItem += 1
                    let progress = Float(currentItem) / Float(totalItems)
                    delegate?.dataImporter(progress: progress)
                }
                
                do {
                    try repository.save()
                } catch {
                    print("Error saving data: \(error)")
                }
                
                do {
                    let count = try repository.countAllProducts()
                    print("Inserted \(count) records!")
                } catch {
                    print("Error saving data: \(error)")
                }
            } else {
                print("Error: 'products' key not found in JSON")
            }
        } catch {
            print("Error decoding JSON: \(error)")
        }
    }
}

