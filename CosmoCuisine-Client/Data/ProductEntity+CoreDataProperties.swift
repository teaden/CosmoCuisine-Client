//
//  ProductEntity+CoreDataProperties.swift
//  CosmoCuisine-Client
//
//  Created by Tyler Eaden on 12/16/24.
//
//

import Foundation
import CoreData


extension ProductEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProductEntity> {
        return NSFetchRequest<ProductEntity>(entityName: "ProductEntity")
    }

    @NSManaged public var id: String?
    @NSManaged public var brand_us: String?
    @NSManaged public var brand_jp: String?
    @NSManaged public var category_us: String?
    @NSManaged public var category_jp: String?
    @NSManaged public var image_us: Data?
    @NSManaged public var image_jp: Data?
    @NSManaged public var energy_us: NSDecimalNumber?
    @NSManaged public var energy_jp: NSDecimalNumber?
    @NSManaged public var fat_us: NSDecimalNumber?
    @NSManaged public var fat_jp: NSDecimalNumber?
    @NSManaged public var sat_fat_us: NSDecimalNumber?
    @NSManaged public var sat_fat_jp: NSDecimalNumber?
    @NSManaged public var trans_fat_us: NSDecimalNumber?
    @NSManaged public var trans_fat_jp: NSDecimalNumber?
    @NSManaged public var cholesterol_us: NSDecimalNumber?
    @NSManaged public var cholesterol_jp: NSDecimalNumber?
    @NSManaged public var carbs_us: NSDecimalNumber?
    @NSManaged public var carbs_jp: NSDecimalNumber?
    @NSManaged public var sugars_us: NSDecimalNumber?
    @NSManaged public var sugars_jp: NSDecimalNumber?
    @NSManaged public var fiber_us: NSDecimalNumber?
    @NSManaged public var fiber_jp: NSDecimalNumber?
    @NSManaged public var proteins_us: NSDecimalNumber?
    @NSManaged public var proteins_jp: NSDecimalNumber?
    @NSManaged public var salt_us: NSDecimalNumber?
    @NSManaged public var salt_jp: NSDecimalNumber?
    @NSManaged public var vit_a_us: NSDecimalNumber?
    @NSManaged public var vit_a_jp: NSDecimalNumber?
    @NSManaged public var vit_c_us: NSDecimalNumber?
    @NSManaged public var vit_c_jp: NSDecimalNumber?
    @NSManaged public var calcium_us: NSDecimalNumber?
    @NSManaged public var calcium_jp: NSDecimalNumber?
    @NSManaged public var iron_us: NSDecimalNumber?
    @NSManaged public var iron_jp: NSDecimalNumber?

}

extension ProductEntity : Identifiable {

}
