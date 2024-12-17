//
//  LoadingViewController.swift
//  CosmoCuisine-Client
//
//  Created by Tyler Eaden on 12/17/24.
//

import UIKit

class LoadingViewController: UIViewController, DataImporterDelegate {

    var dataImporter: DataImporter?
    @IBOutlet weak var progressView: UIProgressView! // Outlet for your progress view

    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set(false, forKey: "hasImportedData")
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }

            // Check UserDefaults and import data
            let hasImportedData = UserDefaults.standard.bool(forKey: "hasImportedData")
            if !hasImportedData {
                self.dataImporter?.delegate = self
                self.dataImporter?.importDataFromJSON()
                UserDefaults.standard.set(true, forKey: "hasImportedData")
            } else {
                print("Products available in CoreData!")
            }

            DispatchQueue.main.async {
                // Instantiate your main view controller from storyboard
                let storyboard = UIStoryboard(name: "Main", bundle: nil)

                let navVC = storyboard.instantiateInitialViewController() as! UINavigationController
                self.view.window?.rootViewController = navVC
                self.view.window?.makeKeyAndVisible()
            }
        }
    }
}

// Implement the DataImporterDelegate method
extension LoadingViewController {
    func dataImporter(progress: Float) {
        DispatchQueue.main.async {
            self.progressView.progress = progress
        }
    }
}
