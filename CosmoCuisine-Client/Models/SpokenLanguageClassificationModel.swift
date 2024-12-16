//
//  SpokenLanguageMlModel.swift
//  CosmoCuisine-Client
//
//  Created by Tyler Eaden on 12/15/24.
//

import UIKit
import CoreML
import SoundAnalysis

protocol ClassifierDelegate {
    func updateResponse(code: Any, strData: Any)
}

class SpokenLanguageClassificationModel: NSObject, SNResultsObserving {
    
    var delegate: ClassifierDelegate?   // Create a delegate for using the protocol
    
    func predict() {
        // Load the Core ML model
        guard let model = try? SpokenLanguageModel(configuration: MLModelConfiguration()) else {
            print("Failed to load the model")
            delegate?.updateResponse(code: "Error", strData: "Failed to load the model") // Inform delegate of error
            return
        }
        
        // Get the file URL for the recording.wav in the app's documents directory
        let fileName = "recording.wav"
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        // Check if the file exists
        guard fileManager.fileExists(atPath: fileURL.path) else {
            print("File does not exist at path: \(fileURL.path)")
            return
        }

        // Create an audio file analyzer
        do {
            let audioFileAnalyzer = try SNAudioFileAnalyzer(url: fileURL)

            // Create a prediction request
            let request = try SNClassifySoundRequest(mlModel: model.model)

            // Perform the prediction
            try audioFileAnalyzer.add(request, withObserver: self)
            audioFileAnalyzer.analyze()

        } catch {
            print("Error analyzing audio: \(error)")
            delegate?.updateResponse(code: "Error", strData: "Error analyzing audio") // Inform delegate of error
        }
    }
    
    // Implement SNResultsObserving methods
    func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let result = result as? SNClassificationResult else { return }
        
        // Get the top classification
       guard let classification = result.classifications.first else { return }
        
        delegate?.updateResponse(code: "Success", strData: classification.identifier) // Send result to delegate
    }

    func request(_ request: SNRequest, didFailWithError error: Error) {
        print("Error with sound classification: \(error)")
        delegate?.updateResponse(code: "Error", strData: "Error with sound classification") // Inform delegate of error
    }

    func requestDidComplete(_ request: SNRequest) {
        print("Sound classification complete.")
    }
}
