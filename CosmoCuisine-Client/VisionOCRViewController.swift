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

    @IBAction func capturePhoto(_ sender: UIButton) {
        self.visionModel.capturePhoto()
    }
    
    let visionModel: VisionModel = VisionModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        visionModel.delegate = self
        self.visionModel.setupCamera(previewView: self.previewView)
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
        
        if let image = newImage {
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let photoPreviewViewController = storyboard.instantiateViewController(withIdentifier: "PhotoPreviewViewController") as! PhotoPreviewViewController
                photoPreviewViewController.delegate = self
                photoPreviewViewController.image = newImage
                self.present(photoPreviewViewController, animated: true, completion: nil)
            }
        }
    }
}

extension VisionOCRViewController: PhotoPreviewDelegate {
    func confirmPhoto() {
        // Send OCR data to CoreData or NetworkingModel functionality here
        dismiss(animated: true)
    }
    
    func retakePhoto() {
        dismiss(animated: true)
    }
}
