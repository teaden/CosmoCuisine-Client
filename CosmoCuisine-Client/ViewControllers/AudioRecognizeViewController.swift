//
//  AudioRecognizeViewController.swift
//  CosmoCuisine-Client
//
//  Created by Tyler Eaden on 12/16/24.
//

import UIKit

class AudioRecognizeViewController: UIViewController, AudioModelDelegate, SpeechRecognitionModelDelegate {
    
    // Instantiate models
    lazy var audioModel: AudioModel = AudioModel()
    lazy var networkingModel: NetworkingModel = NetworkingModel()
    lazy var classifierModel: SpokenLanguageClassificationModel = SpokenLanguageClassificationModel()
    lazy var speechRecognizerModel: SpeechRecognitionModel = SpeechRecognitionModel()
    
    // Create reusable animation for updating responseTextView based on server responses
    lazy var animation = {
        let tmp = CATransition()
        tmp.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        tmp.type = CATransitionType.reveal
        tmp.duration = 0.5
        return tmp
    }()
        
    // Allows for displaying time down to centiseconds of currently recording audio
    private var recordingTimer: Timer?
    private var elapsedTime = 0
    
    // Additional flag that ensures audio has been recording before networking and ML requests
    private var sendable = false
    
    // IBOutlets
    @IBOutlet weak var recordingTimeLabel: UILabel!
    @IBOutlet weak var recordingStatusLabel: UILabel!
    @IBOutlet weak var playRecordingButton: UIButton!
    @IBOutlet weak var startRecordingButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    @IBOutlet weak var getFoodButton: UIButton!
    
    // IBActions
    @IBAction func playRecordingButtonTapped(_ sender: UIButton) {
        audioModel.playAudio()
    }
    
    @IBAction func startRecordingButtonTapped(_ sender: UIButton) {
        audioModel.startRecording()
    }
    
    @IBAction func stopRecordingButtonTapped(_ sender: UIButton) {
        audioModel.stopRecording()
    }
    
    @IBAction func getFoodButtonTapped(_ sender: UIButton) {
        if sendable {
//            classifierModel.predict()
            speechRecognizerModel.transcribeFile()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeStateAndAudio()
    }
    
    // Updates recordingTimeLabel.text with duration of currently recording audio
    func updateRecordingTimeLabel() {
        elapsedTime += 1  // Increment by 1 every 0.01 seconds for centiseconds
        let centiseconds = elapsedTime
        let seconds = centiseconds / 100
        let remainingCentiseconds = centiseconds % 100

        let formattedTime = String(format: "%02d:%02d.%02d", seconds / 60, seconds % 60, remainingCentiseconds)
        recordingTimeLabel.text = formattedTime
    }
    
    // viewDidLoad functionality moved to separate method for readability and maintainability
    private func initializeStateAndAudio() {
        
        DispatchQueue.main.async {
            // Hide all UI elements until permission is granted
            self.recordingTimeLabel.isHidden = true
            self.recordingStatusLabel.isHidden = true
            self.playRecordingButton.isHidden = true
            self.startRecordingButton.isHidden = true
            self.stopRecordingButton.isHidden = true
            self.getFoodButton.isHidden = true
        }
        
        // Manually ask for permission to record
        // Ensures permission not inconveniently asked upon first startRecordingButtonTapped action
        audioModel.askForRecordPermission { [weak self] granted in
            if granted {
                
                // Also ask for permission to utilize speech recognition
                self?.speechRecognizerModel.requestSpeechRecognitionAuthorization { [weak self] status in
                    if status == .authorized {
                        // Update the UI after mic access granted
                        DispatchQueue.main.async {
                            
                            // Set up delegates and data sources after mic and speech recognizer access
                            self?.audioModel.delegate = self
                            self?.speechRecognizerModel.delegate = self
                            
                            // These elements should always be visible after accesses granted
                            self?.startRecordingButton.isHidden = false
                            self?.getFoodButton.isHidden = true
                            
                            // Allow playback and calibration if audio feature in file system
                            if self?.audioModel.checkRecordingFile() == true {
                                self?.playRecordingButton.isHidden = false
                                self?.getFoodButton.isHidden = false
                                
                                // Can send recording from app document filesystem to server
                                self?.sendable = true
                            }
                        }
                    } else {
                        // Provide alert expressing that mic access is necessary
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "Speech Recognizer Access Denied",
                                                          message: "Please enable speech recognizer access in Settings to use this app.",
                                                          preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default))
                            self?.present(alert, animated: true)
                        }
                    }
                }
            } else {
                // Provide alert expressing that mic access is necessary
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Microphone Access Denied",
                                                  message: "Please enable microphone access in Settings to use this app.",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true)
                }
            }
        }
    }
}

// AudioModelDelegate methods
extension AudioRecognizeViewController {
    // Begin timer for updating recordingTimelabel with currently recording audio duration
    func audioRecordingDidStart() {
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] timer in
            self?.updateRecordingTimeLabel()
        }
        
        // Reset flag that indicates whether networking request is valid since new feature is being recorded
        self.sendable = false
        
        // Show necessary UI elements (e.g., stopRecordingButton while recording)
        recordingTimeLabel.isHidden = false
        stopRecordingButton.isHidden = false
        
        // Hide all other UI elements
        startRecordingButton.isHidden = true
        playRecordingButton.isHidden = true
        getFoodButton.isHidden = true
    }
    
    func audioRecordingDidFinish(with audioFlag: RecordingEnum) {
        // Invalidate timer linked to recordingTimeLabel updates upon end of recording
        recordingTimer?.invalidate()
        recordingTimer = nil
        elapsedTime = 0
        recordingTimeLabel.isHidden = true
        recordingTimeLabel.text = "00:00.00"
        
        // Show necessary UI elements (e.g., startRecordingButton when not recording)
        startRecordingButton.isHidden = false
        getFoodButton.isHidden = false
        
        // Hide unnecessary UI elements (e.g., stopRecordingButton when not recording)
        stopRecordingButton.isHidden = true
                
        if audioFlag == .recordingSuccess {
            playRecordingButton.isHidden = false
            getFoodButton.isHidden = false
            
            // Can send newly recorded audio file from app document filesystem to server
            self.sendable = true
        }
        
        recordingStatusLabel.text = audioFlag.rawValue
        recordingStatusLabel.isHidden = false
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] timer in
            self?.recordingStatusLabel.isHidden = true
        }
    }
}

// SpeechRecognitionModelDelegate
extension AudioRecognizeViewController {
    func speechRecognitionDidFinish(transcription: String) {
        print("Recognized Text: \(transcription)")
    }
    func speechRecognitionDidFail(error: Error) {
        print("Error: \(error)")
    }
}
