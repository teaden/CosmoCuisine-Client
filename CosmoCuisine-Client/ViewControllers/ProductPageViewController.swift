//
//  ProductPageViewController.swift
//  CosmoCuisine-Client
//
//  Created by Tyler Eaden on 12/17/24.
//

import UIKit

class ProductPageViewController: UIViewController {
    let product: ProductEntity
    let lang: String
    let query: String
    var pageIndex: Int = 0

    init(product: ProductEntity, lang: String, query: String) {
        self.product = product
        self.lang = lang
        self.query = query
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

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

        // If query == "cat", show images regardless of language
        if query == "cat" {
            let imagesStack = UIStackView()
            imagesStack.axis = .vertical
            imagesStack.alignment = .center
            imagesStack.spacing = 10
            imagesStack.translatesAutoresizingMaskIntoConstraints = false

            // image_jp display
            if let imageDataJp = product.image_jp {
                let imageViewJp = UIImageView()
                imageViewJp.contentMode = .scaleAspectFit
                imageViewJp.translatesAutoresizingMaskIntoConstraints = false
                imageViewJp.image = UIImage(data: imageDataJp)
                imagesStack.addArrangedSubview(imageViewJp)
                imageViewJp.heightAnchor.constraint(equalToConstant: 100).isActive = true
            } else {
                let label = UILabel()
                label.text = "No JP Image Available"
                label.textAlignment = .center
                imagesStack.addArrangedSubview(label)
            }

            // image_us display (if available)
            if let imageDataUs = product.image_us {
                let imageViewUs = UIImageView()
                imageViewUs.contentMode = .scaleAspectFit
                imageViewUs.translatesAutoresizingMaskIntoConstraints = false
                imageViewUs.image = UIImage(data: imageDataUs)
                imagesStack.addArrangedSubview(imageViewUs)
                imageViewUs.heightAnchor.constraint(equalToConstant: 100).isActive = true
            } else {
                let label = UILabel()
                label.text = "No US Image Available"
                label.textAlignment = .center
                imagesStack.addArrangedSubview(label)
            }

            mainStack.addArrangedSubview(imagesStack)
        }

        // Add a brand/category label at the top if available
        let brandCatLabel = UILabel()
        brandCatLabel.textAlignment = .center

        // Depending on lang, build either Japanese or English table
        if lang == "ja" {
            if let brand = product.brand_jp, let cat = product.category_jp {
                brandCatLabel.text = "\(brand)\(cat)"
            } else {
                brandCatLabel.text = "利用可能なブランドはありません"
            }
            
            brandCatLabel.font = UIFont.boldSystemFont(ofSize: 20)
            mainStack.addArrangedSubview(brandCatLabel)
            addJapaneseNutritionTable(to: mainStack)
        } else {
            if let brand = product.brand_us, let cat = product.category_us {
                brandCatLabel.text = "\(brand) \(cat)"
            } else {
                brandCatLabel.text = "No brand available"
            }
            
            brandCatLabel.font = UIFont.boldSystemFont(ofSize: 20)
            mainStack.addArrangedSubview(brandCatLabel)
            addEnglishNutritionTable(to: mainStack)
        }

        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.heightAnchor.constraint(equalToConstant: 20).isActive = true
        mainStack.addArrangedSubview(spacer)
    }

    private func addEnglishNutritionTable(to stack: UIStackView) {
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
            valueLabel.text = value != nil ? value!.stringValue : "N/A"
            valueLabel.font = UIFont.systemFont(ofSize: 16)
            valueLabel.textAlignment = .right
            valueLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

            rowStack.addArrangedSubview(titleLabel)
            rowStack.addArrangedSubview(valueLabel)
            return rowStack
        }

        // Add rows for each nutrient (English)
        stack.addArrangedSubview(makeRow(title: "Energy (cal)", value: product.energy_us))
        stack.addArrangedSubview(makeRow(title: "Fat (g)", value: product.fat_us))
        stack.addArrangedSubview(makeRow(title: "Saturated Fat (g)", value: product.sat_fat_us))
        stack.addArrangedSubview(makeRow(title: "Trans Fat (g)", value: product.trans_fat_us))
        stack.addArrangedSubview(makeRow(title: "Cholesterol (mg)", value: product.cholesterol_us))
        stack.addArrangedSubview(makeRow(title: "Carbohydrates (g)", value: product.carbs_us))
        stack.addArrangedSubview(makeRow(title: "Sugars (g)", value: product.sugars_us))
        stack.addArrangedSubview(makeRow(title: "Fiber (g)", value: product.fiber_us))
        stack.addArrangedSubview(makeRow(title: "Protein (g)", value: product.proteins_us))
        stack.addArrangedSubview(makeRow(title: "Salt (mg)", value: product.salt_us))
        stack.addArrangedSubview(makeRow(title: "Vitamin A (µg)", value: product.vit_a_us))
        stack.addArrangedSubview(makeRow(title: "Vitamin C (mg)", value: product.vit_c_us))
    }

    private func addJapaneseNutritionTable(to stack: UIStackView) {
        func makeRowJP(title: String, value: NSDecimalNumber?, unit: String) -> UIStackView {
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
                valueLabel.text = val.stringValue + unit
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

        // Add Japanese rows
        stack.addArrangedSubview(makeRowJP(title: "エネルギー", value: product.energy_jp, unit: "kcal"))
        stack.addArrangedSubview(makeRowJP(title: "たんぱく質", value: product.proteins_jp, unit: "g"))
        stack.addArrangedSubview(makeRowJP(title: "脂質", value: product.fat_jp, unit: "g"))
        stack.addArrangedSubview(makeRowJP(title: "炭水化物", value: product.carbs_jp, unit: "g"))
        stack.addArrangedSubview(makeRowJP(title: "糖質", value: product.sugars_jp, unit: "g"))
        stack.addArrangedSubview(makeRowJP(title: "食物繊維", value: product.fiber_jp, unit: "g"))
    }
}
