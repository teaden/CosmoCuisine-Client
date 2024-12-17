//
//  CoreDataRepository.swift
//  CosmoCuisine-Client
//
//  Created by Tyler Eaden on 12/16/24.
//

import CoreData

class CoreDataRepository {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fetchMatchingBrandsJP(for strings: [String]) throws -> [ProductEntity] {
        guard !strings.isEmpty else { return [] }
        
        return try context.performAndWait {
            let request: NSFetchRequest<ProductEntity> = ProductEntity.fetchRequest()
            request.predicate = NSPredicate(format: "brand_jp IN %@", strings)
            return try context.fetch(request)
        }
    }
    
    func fetchPartialMatchingBrandsJP(for strings: [String]) throws -> [ProductEntity] {
        guard !strings.isEmpty else { return [] }
        
        return try context.performAndWait {
            // Create a series of subpredicates, each checking if brand_jp CONTAINS one of the strings
            let subPredicates = strings.map { str in
                NSPredicate(format: "brand_jp CONTAINS[cd] %@", str)
            }
            
            // Combine all subpredicates with OR logic
            let compoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: subPredicates)
            
            let request: NSFetchRequest<ProductEntity> = ProductEntity.fetchRequest()
            request.predicate = compoundPredicate

            return try context.fetch(request)
        }
    }
    
    func fetchLevDistBrandsJP(for strings: [String]) throws -> [ProductEntity] {
        guard !strings.isEmpty else { return [] }

        return try context.performAndWait {
            // Fetch all products or a broad set of them
            let request: NSFetchRequest<ProductEntity> = ProductEntity.fetchRequest()
            let allProducts = try context.fetch(request)

            // Filter in memory based on Levenshtein distance
            // A product matches if ANY of the given input strings has a distance of <= 1 from brand_jp
            return allProducts.filter { product in
                guard let brand = product.brand_jp, !brand.isEmpty else { return false }
                for str in strings {
                    let distance = StringComparison.levenshteinDistance(brand, str)
                    if distance <= 1 {
                        return true
                    }
                }
                return false
            }
        }
    }
    
    func fetchMatchingCategoriesJP(for strings: [String]) throws -> [ProductEntity] {
        guard !strings.isEmpty else { return [] }

        return try context.performAndWait {
            let request: NSFetchRequest<ProductEntity> = ProductEntity.fetchRequest()
            let allProducts = try context.fetch(request)

            return allProducts.filter { product in
                guard let category = product.category_jp, !category.isEmpty else { return false }

                for originalStr in strings {
                    // Generate all substrings of originalStr
                    let substrings = StringComparison.allSubstrings(of: originalStr)

                    // Check if any substring exactly equals category
                    for substring in substrings {
                        if category == substring {
                            return true
                        }
                    }
                }
                return false
            }
        }
    }
    
    func fetchLevDistCategoriesJP(for strings: [String]) throws -> [ProductEntity] {
        guard !strings.isEmpty else { return [] }

        return try context.performAndWait {
            let request: NSFetchRequest<ProductEntity> = ProductEntity.fetchRequest()
            let allProducts = try context.fetch(request)

            return allProducts.filter { product in
                guard let category = product.category_jp, !category.isEmpty else { return false }

                for originalStr in strings {
                    // Generate all substrings of originalStr
                    let substrings = StringComparison.allSubstrings(of: originalStr)

                    // Check each substring's Levenshtein distance to category
                    for substring in substrings {
                        let distance = StringComparison.levenshteinDistance(category, substring)
                        if distance <= 1 {
                            return true
                        }
                    }
                }
                return false
            }
        }
    }
    
    func fetchLevDistCategoriesUS(for strings: [String]) throws -> [ProductEntity] {
        guard !strings.isEmpty else { return [] }

        return try context.performAndWait {
            // Fetch all products or a broad set of them
            let request: NSFetchRequest<ProductEntity> = ProductEntity.fetchRequest()
            let allProducts = try context.fetch(request)

            // Filter in memory based on Levenshtein distance
            // A product matches if ANY of the given input strings has a distance of <= 1 from category_us
            return allProducts.filter { product in
                guard let category = product.category_us, !category.isEmpty else { return false }
                for str in strings {
                    // Compare lowercase of OCR string to lowercase of database record categories
                    let distance = StringComparison.levenshteinDistance(category.lowercased(), str.lowercased())
                    if distance <= 1 {
                        return true
                    }
                }
                return false
            }
        }
    }
    
    // Returns the total number of ProductEntity records in the store.
    func countAllProducts() throws -> Int {
        return try context.performAndWait {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = ProductEntity.fetchRequest()
            return try context.count(for: fetchRequest)
        }
    }
    
    // Inserts a new ProductEntity into the context from the given ProductData
    @discardableResult
    func insertProduct(from itemData: ProductData) throws -> ProductEntity {
        return try context.performAndWait {
            let product = ProductEntity(context: self.context)
            
            product.id = itemData.id
            product.brand_us = itemData.brand_us
            product.brand_jp = itemData.brand_jp
            product.category_us = itemData.category_us
            product.category_jp = itemData.category_jp
            
            product.energy_us = NSDecimalNumber(string: itemData.energy_us)
            product.energy_jp = NSDecimalNumber(string: itemData.energy_jp)
            product.fat_us = NSDecimalNumber(string: itemData.fat_us)
            product.fat_jp = NSDecimalNumber(string: itemData.fat_jp)
            product.sat_fat_us = NSDecimalNumber(string: itemData.sat_fat_us)
            product.sat_fat_jp = NSDecimalNumber(string: itemData.sat_fat_jp)
            product.trans_fat_us = NSDecimalNumber(string: itemData.trans_fat_us)
            product.trans_fat_jp = NSDecimalNumber(string: itemData.trans_fat_jp)
            product.cholesterol_us = NSDecimalNumber(string: itemData.cholesterol_us)
            product.cholesterol_jp = NSDecimalNumber(string: itemData.cholesterol_jp)
            product.carbs_us = NSDecimalNumber(string: itemData.carbs_us)
            product.carbs_jp = NSDecimalNumber(string: itemData.carbs_jp)
            product.sugars_us = NSDecimalNumber(string: itemData.sugars_us)
            product.sugars_jp = NSDecimalNumber(string: itemData.sugars_jp)
            product.fiber_us = NSDecimalNumber(string: itemData.fiber_us)
            product.fiber_jp = NSDecimalNumber(string: itemData.fiber_jp)
            product.proteins_us = NSDecimalNumber(string: itemData.proteins_us)
            product.proteins_jp = NSDecimalNumber(string: itemData.proteins_jp)
            product.salt_us = NSDecimalNumber(string: itemData.salt_us)
            product.salt_jp = NSDecimalNumber(string: itemData.salt_jp)
            product.vit_a_us = NSDecimalNumber(string: itemData.vit_a_us)
            product.vit_a_jp = NSDecimalNumber(string: itemData.vit_a_jp)
            product.vit_c_us = NSDecimalNumber(string: itemData.vit_c_us)
            product.vit_c_jp = NSDecimalNumber(string: itemData.vit_c_jp)
            product.calcium_us = NSDecimalNumber(string: itemData.calcium_us)
            product.calcium_jp = NSDecimalNumber(string: itemData.calcium_jp)
            product.iron_us = NSDecimalNumber(string: itemData.iron_us)
            product.iron_jp = NSDecimalNumber(string: itemData.iron_jp)

            if let imageNameUs = itemData.image_us {
                let imageNameComponents = imageNameUs.split(separator: ".")
                if imageNameComponents.count == 2 {
                    let name = String(imageNameComponents[0].split(separator: "/")[2])
                    let ext = String(imageNameComponents[1])
                    if let imageURL = Bundle.main.url(forResource: name, withExtension: ext),
                       let imageData = try? Data(contentsOf: imageURL) {
                        product.image_us = imageData
                    } else {
                        product.image_us = nil
                    }
                } else {
                    product.image_us = nil
                }
            } else {
                product.image_us = nil
            }

            let imageNameComponents = itemData.image_jp.split(separator: ".")
            if imageNameComponents.count == 2 {
                let name = String(imageNameComponents[0].split(separator: "/")[2])
                let ext = String(imageNameComponents[1])
                if let imageURL = Bundle.main.url(forResource: name, withExtension: ext),
                   let imageData = try? Data(contentsOf: imageURL) {
                    product.image_jp = imageData
                } else {
                    product.image_jp = nil
                }
            } else {
                product.image_jp = nil
            }

            return product
        }
    }
    
    // Remove all ProductEntity records from the CoreData database
    func deleteAllProducts() throws {
        try context.performAndWait {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = ProductEntity.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            try context.execute(deleteRequest)
        }
    }

    // Save the context after insertions or deletions
    func save() throws {
        try context.performAndWait {
            if context.hasChanges {
                try context.save()
            }
        }
    }
}
