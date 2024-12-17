//
//  VisionModel.swift
//  CosmoCuisine-Client
//
//  Created by Tyler Eaden on 12/15/24.
//

import UIKit
import AVFoundation
import Vision


protocol VisionServiceDelegate {
    func showPreview(newImage: UIImage?)
    func handleCamera()
    func processOCRResults(ocrResults: [String])
}

class VisionModel: NSObject {
    
    var delegate: VisionServiceDelegate?
    
    // MARK: - AVFoundation Properties
    var captureSession: AVCaptureSession!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var photoOutput = AVCapturePhotoOutput()
    
    func setupCamera(previewView: UIView) {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                   for: .video,
                                                   position: .back),
              let input = try? AVCaptureDeviceInput(device: camera),
              captureSession.canAddInput(input) else {
            print("Cannot access back camera.")
            return
        }
        
        captureSession.addInput(input)
        
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.frame = previewView.bounds
        previewView.layer.insertSublayer(videoPreviewLayer, at: 0)
    }
    
    func startSession() {
        DispatchQueue.global(qos: .background).async {
            if let session = self.captureSession, !session.isRunning {
                session.startRunning()
            }
        }
    }
    
    
    func stopSession() {
        DispatchQueue.global(qos: .background).async {
            if let session = self.captureSession, session.isRunning {
                session.stopRunning()
            }
        }
    }
    
    
    func capturePhoto() {
        if self.delegate != nil {
            let settings = AVCapturePhotoSettings()
            photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }
    
    func processImage(_ image: UIImage) {
        guard let cgImage = image.cgImage else {
            print("No CGImage found")
            return
        }
                
        let request = VNRecognizeTextRequest { request, error in
    
            if let error = error {
                print("Text recognition error: \(error)")
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation], !observations.isEmpty else {
                print("No text recognized.")
                return
            }
            
            let recognizedStrings: [String] = observations.compactMap { observation in
                return observation.topCandidates(1).first?.string
            }
            
            print("Recognized Strings:\n", recognizedStrings)
            self.delegate?.processOCRResults(ocrResults: recognizedStrings)
            
            // Draw bounding boxes
            self.drawBoundingBoxes(for: observations, on: image)
        }
        
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.recognitionLanguages = ["ja"]   // Set language to Japanese
        
        let cgOrientation = CGImagePropertyOrientation(image.imageOrientation)
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, orientation: cgOrientation, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler.perform([request])
            } catch {
                print("Failed to perform OCR.")
            }
        }
    }

    func drawBoundingBoxes(for observations: [VNRecognizedTextObservation], on image: UIImage) {
        let imageSize = image.size
        let scale: CGFloat = 0
        UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)
        image.draw(at: CGPoint.zero)
        
        let context = UIGraphicsGetCurrentContext()!
        context.setLineWidth(6.0)
        context.setStrokeColor(UIColor.green.cgColor)
        
        for observation in observations {
            guard let topCandidate = observation.topCandidates(1).first else { continue }
            
            // Define the full range of the recognized string
            let fullRange = topCandidate.string.startIndex..<topCandidate.string.endIndex
            
            // Get the bounding box as a VNRectangleObservation
            if let rectangleObservation = try? topCandidate.boundingBox(for: fullRange) {
               
                let boundingBox = rectangleObservation.boundingBox
                
                // Convert the normalized bounding box to image coordinates
                let rect = CGRect(
                    x: boundingBox.minX * imageSize.width,
                    y: (1 - boundingBox.maxY) * imageSize.height,
                    width: boundingBox.width * imageSize.width,
                    height: boundingBox.height * imageSize.height
                )
                
                // Draw the bounding box
                context.stroke(rect)
            }
        }
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        delegate?.showPreview(newImage: newImage)
    }
}

extension VisionModel: AVCapturePhotoCaptureDelegate {
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
        delegate?.handleCamera()
        processImage(image)
    }
}
