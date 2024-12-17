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

            if let imageName = itemData.image_us,
               let imageURL = Bundle.main.url(forResource: imageName, withExtension: nil),
               let imageData = try? Data(contentsOf: imageURL) {
                product.image_us = imageData
            } else {
                product.image_us = nil
            }

            let imageJpURL = Bundle.main.url(forResource: itemData.image_jp, withExtension: nil)
            if let jpURL = imageJpURL {
               let imageJpData = try? Data(contentsOf: jpURL)
               product.image_jp = imageJpData
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
