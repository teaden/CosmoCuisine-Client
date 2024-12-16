//
//  SpeechRecognitionModel.swift
//  CosmoCuisine-Client
//
//  Created by Tyler Eaden on 12/15/24.
//

import Foundation
import Speech

// Delegate protocol to handle the transcription result or errors
protocol SpeechRecognitionModelDelegate: AnyObject {
    func speechRecognitionDidFinish(transcription: String)
    func speechRecognitionDidFail(error: Error)
}

class SpeechRecognitionModel {
    
    weak var delegate: SpeechRecognitionModelDelegate?
    
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    // MARK: - Public Methods
    // Check authorization for Speech Recognition. Your caller should handle UI updates based on status.
    func requestSpeechRecognitionAuthorization(completion: @escaping (SFSpeechRecognizerAuthorizationStatus) -> Void) {
        SFSpeechRecognizer.requestAuthorization { status in
            if status == .authorized {
                // Instantiate recognizer if access is granted
                self.speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
                print("Speech Recognition access granted!")
            } else {
                print("Speech Recognition access unapproved!")
            }
            completion(status)
        }
    }
    
   
    // Transcribe an audio file given a language identifier and a URL to the audio file
    func transcribeFile() {
        
        // Cancel any ongoing tasks
        cancelTranscription()
        
        // Get the file URL for the recording.wav in the app's documents directory
        let fileName = "recording.wav"
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        // Create a recognition request using the file URL
        let request = SFSpeechURLRecognitionRequest(url: fileURL)
        // Optional: configure the request, e.g., partial results if desired
        request.shouldReportPartialResults = false
        
        guard let recognizer = speechRecognizer else {
            print("No speech recognizer instantiated")
            return
        }
        
        guard let speechDelegate = self.delegate else {
            print("No speech delegate assigned")
            return
        }
        
        recognitionTask = recognizer.recognitionTask(with: request) { [weak self] (result, error) in
            // Notify and return early if an error
            if let error = error {
                // If the error ends the task, handle it here
                speechDelegate.speechRecognitionDidFail(error: error)
                self?.recognitionTask = nil
                return
            }
                
            // Notify the delegate if final result available
            if let result = result, result.isFinal {
                let transcription = result.bestTranscription.formattedString
                speechDelegate.speechRecognitionDidFinish(transcription: transcription)
                self?.recognitionTask = nil
            }
        }
    }
    
    // MARK: - Optional: Cancel or Cleanup
    // Cancel any ongoing transcription
    func cancelTranscription() {
        recognitionTask?.cancel()
        recognitionTask = nil
    }
}

