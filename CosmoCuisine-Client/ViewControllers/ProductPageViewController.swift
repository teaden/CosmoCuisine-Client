//
//  ProductPageViewController.swift
//  CosmoCuisine-Client
//
//  Created by Tyler Eaden on 12/17/24.
//

import UIKit

class ProductPageViewController: UIViewController {
    let product: ProductEntity
    var pageIndex: Int = 0

    init(product: ProductEntity) {
        self.product = product
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        // Create a main vertical stack for the entire nutrition facts layout
        let mainStack = UIStackView()
        mainStack.axis = .vertical
        mainStack.alignment = .fill
        mainStack.spacing = 10
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16)
        ])

        // Brand Label at the top
        let brandCatLabel = UILabel()
        brandCatLabel.textAlignment = .center
        if let brand = product.brand_us, let cat = product.category_us {
            brandCatLabel.text = "\(brand) \(cat)"
        } else {
            brandCatLabel.text = "No brand available"
        }
        brandCatLabel.font = UIFont.boldSystemFont(ofSize: 20)
        mainStack.addArrangedSubview(brandCatLabel)

        // We'll create rows for each nutrient
        // Helper function to create a row
        func makeRow(title: String, value: NSDecimalNumber?) -> UIStackView {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.alignment = .firstBaseline
            rowStack.spacing = 10

            let titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            titleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)

            let valueLabel = UILabel()
            if let val = value {
                // Assuming these values represent per serving or per 100g.
                // Format as string, could also append units if desired.
                valueLabel.text = val.stringValue
            } else {
                valueLabel.text = "N/A"
            }
            valueLabel.font = UIFont.systemFont(ofSize: 16)
            valueLabel.textAlignment = .right
            valueLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

            rowStack.addArrangedSubview(titleLabel)
            rowStack.addArrangedSubview(valueLabel)
            return rowStack
        }

        // Add rows for each nutrient
        // You can label them as desired. For example, "Energy (kcal)" if appropriate.
        mainStack.addArrangedSubview(makeRow(title: "Energy (cal)", value: product.energy_us))
        mainStack.addArrangedSubview(makeRow(title: "Fat (g)", value: product.fat_us))
        mainStack.addArrangedSubview(makeRow(title: "Saturated Fat (g)", value: product.sat_fat_us))
        mainStack.addArrangedSubview(makeRow(title: "Trans Fat (g)", value: product.trans_fat_us))
        mainStack.addArrangedSubview(makeRow(title: "Cholesterol (mg)", value: product.cholesterol_us))
        mainStack.addArrangedSubview(makeRow(title: "Carbohydrates (g)", value: product.carbs_us))
        mainStack.addArrangedSubview(makeRow(title: "Sugars (g)", value: product.sugars_us))
        mainStack.addArrangedSubview(makeRow(title: "Fiber (g)", value: product.fiber_us))
        mainStack.addArrangedSubview(makeRow(title: "Protein (g)", value: product.proteins_us))
        mainStack.addArrangedSubview(makeRow(title: "Salt (mg)", value: product.salt_us))
        mainStack.addArrangedSubview(makeRow(title: "Vitamin A (µg)", value: product.vit_a_us))
        mainStack.addArrangedSubview(makeRow(title: "Vitamin C (mg)", value: product.vit_c_us))

        // Optional: If you want to show data from jp versions, you could add another section
        // or integrate them the same way. For now, let's just keep US values.

        // Add spacing at the bottom
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.heightAnchor.constraint(equalToConstant: 20).isActive = true
        mainStack.addArrangedSubview(spacer)
    }
}
