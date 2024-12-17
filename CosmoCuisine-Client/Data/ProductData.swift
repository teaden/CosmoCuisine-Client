//
//  ProductData.swift
//  CosmoCuisine-Client
//
//  Created by Tyler Eaden on 12/17/24.
//

import Foundation

struct ProductData: Codable {
    let id: String
    let brand_us: String
    let brand_jp: String
    let category_us: String
    let category_jp: String
    let image_us: String?
    let image_jp: String
    let energy_us: String
    let energy_jp: String
    let fat_us: String
    let fat_jp: String
    let sat_fat_us: String
    let sat_fat_jp: String
    let trans_fat_us: String
    let trans_fat_jp: String
    let cholesterol_us: String
    let cholesterol_jp: String
    let carbs_us: String
    let carbs_jp: String
    let sugars_us: String
    let sugars_jp: String
    let fiber_us: String
    let fiber_jp: String
    let proteins_us: String
    let proteins_jp: String
    let salt_us: String
    let salt_jp: String
    let vit_a_us: String
    let vit_a_jp: String
    let vit_c_us: String
    let vit_c_jp: String
    let calcium_us: String
    let calcium_jp: String
    let iron_us: String
    let iron_jp: String
}
