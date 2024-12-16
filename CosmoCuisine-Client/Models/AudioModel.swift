//
//  AudioModel.swift
//  CosmoCuisine-Client
//
//  Created by Tyler Eaden on 12/15/24.
//

import AVFoundation

// AudioRecognizeViewController will conform to this protocol to handle UI updates and signaling to MlaasModel that audio is recorded
protocol AudioModelDelegate: AnyObject {
    func audioRecordingDidStart()                                   // Called when audio recording starts
    func audioRecordingDidFinish(with audioFlag: RecordingEnum)     // Called when audio recording finishes
}

// AudioModelDelegate SklearnViewController uses recording case raw values for label updates
enum RecordingEnum: String {
    case recordingSuccess = "Successful Recording!"
    case recordingFail = "Recording Failed!"
    case playbackFileDoesNotExist = "Record Before Play!"
    case playbackFailed = "Playback Failed!"
}

// Model responsible for recording, saving, and playback of audio
class AudioModel: NSObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    private let filename = "recording.wav"

    weak var delegate: AudioModelDelegate?          // AudioModelDelegate reference (i.e., AudioRecognizeViewController)
    private var audioRecorder: AVAudioRecorder!     // Handles audio recording
    private var audioPlayer: AVAudioPlayer?         // Handles playback of audio
    
    // Ensures audio recording is stopped after a finite amount of time if user does not call stopRecording
    private var recordingTimer: Timer?
    private var isManuallyStopped = false

    // Starts the audio recording process
    func startRecording() {
        // Configure and activate the audio session
        let audioSession = AVAudioSession.sharedInstance()
        isManuallyStopped = false   // Ensure recordings can be automatically stopped again
        
        do {
            try audioSession.setCategory(.record, mode: .default, options: [])
            try audioSession.setActive(true)
        
            // Get URL to the documents directory to save recording as 'recording.wav' file
            let audioFilename = retrieveFilePath()
            
            // Delete any previous recording
            if checkRecordingFile() {
                try? FileManager.default.removeItem(at: audioFilename)
            }

            // Audio recording settings
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatLinearPCM),              // Linear PCM audio format for wav files
                AVSampleRateKey: 48000.0,                               // Match current device sampling rate
                AVNumberOfChannelsKey: 1,                               // Mono channel
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue  // High audio quality
            ]

            do {
                // Initialize AVAudioRecorder with specified URL and settings
                audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
                // Set model as AVAudioRecorderDelegate delegate to receive recording events
                audioRecorder.delegate = self
                
                // Start recording
                delegate?.audioRecordingDidStart()
                audioRecorder.record()
                
                // Automatically stop recording after 10 seconds if user does not call stopRecording before then
                recordingTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { [weak self] _ in
                    guard let self = self else { return }

                    if !self.isManuallyStopped {
                        self.audioRecorder.stop()
                    }
                }
                
            } catch {
                // Notify the delegate if audio recording initialization fails
                print("Failed to initialize audio recording: \(error)")
                delegate?.audioRecordingDidFinish(with: .recordingFail)
            }
        } catch {
            // Notify the delegate if audio session fails to activate
            print("Failed to activate audio session: \(error)")
            delegate?.audioRecordingDidFinish(with: .recordingFail)
        }
    }
        
    // Stops the audio recording process
    func stopRecording() {
        isManuallyStopped = true    // Ensures stopRecording is not called twice
        audioRecorder.stop()
        
        // Invalidate and deallocate the timer if used for automatically stopping the recording
        recordingTimer?.invalidate()
        recordingTimer = nil
    }
    
    // Plays audio recorded in "recording.wav"
    func playAudio() {
        
        let audioFilename = retrieveFilePath()
        
        if checkRecordingFile() {
            
            let audioSession = AVAudioSession.sharedInstance()
            
            do {
                try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
                try audioSession.setActive(true)
                
                audioPlayer = try AVAudioPlayer(contentsOf: audioFilename)
                audioPlayer?.delegate = self
                audioPlayer?.play()
            } catch {
                // Notify the delegate that recorded audio failed to play
                print("Failed to play audio recording: \(error)")
                delegate?.audioRecordingDidFinish(with: .playbackFailed)
            }
        } else {
            // Handle the case where the file does not exist
            delegate?.audioRecordingDidFinish(with: .playbackFileDoesNotExist)
        }
    }

    // Call below AVAudioRecorder delegate method when the audio recording finishes
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        
        // Deactivate the audio session
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            // Output to console if audio session fails to deactivate
            print("Failed to deactivate audio session: \(error)")
        }

        if flag { // If recording was successful
            // Notify delegate that the recording finished successfully
            delegate?.audioRecordingDidFinish(with: .recordingSuccess)
        } else {
            // Notify delegate that the recording process failed
            delegate?.audioRecordingDidFinish(with: .recordingFail)
        }
    }
    
    // Call below AVAudioRecorder delegate method when the audio recording finishes
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            // Output to console if audio session fails to deactivate
            print("Failed to deactivate audio session: \(error)")
        }
    }
    
    // Manually request permission to record
    func askForRecordPermission(completion: @escaping (Bool) -> Void) {
        AVAudioApplication.requestRecordPermission { granted in
            if granted {
                print("Microphone access granted!")
            } else {
                print("Microphone access denied!")
            }
            completion(granted)
        }
    }
    
    // See if there is a recording in documents
    // Will determine if play button is enabled upon SklearnViewController viewDidLoad
    func checkRecordingFile() -> Bool {
        let audioFilename = retrieveFilePath()
        if FileManager.default.fileExists(atPath: audioFilename.path) {
            return true
        }
        return false
    }
    
    // Return documents URL at which audio file exists
    private func retrieveFilePath() -> URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentsURL.appendingPathComponent(filename)
        return audioFilename
    }
}
