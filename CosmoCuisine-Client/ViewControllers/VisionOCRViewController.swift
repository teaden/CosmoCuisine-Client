//
//  VisionOCRViewController.swift
//  CosmoCuisine-Client
//
//  Created by Tyler Eaden on 12/13/24.
//

import UIKit
import AVFoundation
import Vision

class VisionOCRViewController: UIViewController {
    
    // MARK: - UI Elements
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var processingLabel: UILabel!
    @IBOutlet weak var photoCaptureButton: UIButton!
    
    @IBAction func capturePhoto(_ sender: UIButton) {
        processingLabel.isHidden = false
        photoCaptureButton.isHidden = true
        
        self.visionModel.capturePhoto()
    }
    
    lazy var visionModel: VisionModel = VisionModel()
    var ocrResults: [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        processingLabel.isHidden = true
        visionModel.delegate = self
        self.visionModel.setupCamera(previewView: self.previewView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.visionModel.startSession()
    }
}

extension VisionOCRViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        
        guard error == nil else {
            print("Error capturing photo: \(String(describing: error))")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            print("Failed to convert photo to UIImage.")
            return
        }
        
        // Now that we have an image, run OCR
        self.visionModel.processImage(image)
    }
}

extension VisionOCRViewController: VisionServiceDelegate {
    func showPreview(newImage: UIImage?) {
        
        if newImage != nil {
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let photoPreviewViewController = storyboard.instantiateViewController(withIdentifier: "PhotoPreviewViewController") as! PhotoPreviewViewController
                photoPreviewViewController.delegate = self
                photoPreviewViewController.image = newImage
                self.present(photoPreviewViewController, animated: true, completion: nil)
            }
        }
    }
    
    func handleCamera() {
        self.visionModel.stopSession()
    }
    
    func processOCRResults(ocrResults: [String]) {
        self.ocrResults = ocrResults
    }
}

extension VisionOCRViewController: PhotoPreviewDelegate {
    func confirmPhoto() {
        // Send OCR data to CoreData or NetworkingModel functionality here
        dismiss(animated: true)
        let repository = CoreDataRepository(context: PersistenceController.shared.container.viewContext)
        let resultsVC = ResultsViewController(repository: repository, ocrResults: self.ocrResults!, query: "brand", lang: "en")
        self.navigationController?.pushViewController(resultsVC, animated: true)
    }
    
    func retakePhoto() {
        dismiss(animated: true)
    }
    
    func restoreUI() {
        self.visionModel.startSession()
        processingLabel.isHidden = true
        photoCaptureButton.isHidden = false
    }
}
