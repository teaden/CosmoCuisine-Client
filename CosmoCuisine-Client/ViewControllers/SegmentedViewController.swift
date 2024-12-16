//
//  SegmentedViewController.swift
//  CosmoCuisine-Client
//
//  Created by Tyler Eaden on 12/16/24.
//

import UIKit

class SegmentedViewController: UIViewController {
    
    
    @IBOutlet weak var visionContainer: UIView!
    @IBOutlet weak var audioContainer: UIView!
    
    // Hides AudioRecognizeView and shows VisionOCRView or vice versa based on SegmentedControl value
    @IBAction func changeSegment(_ sender: UISegmentedControl) {
        if (sender.selectedSegmentIndex == 0) {
            self.audioContainer.isHidden = true;
            self.visionContainer.isHidden = false;
        } else {
            self.visionContainer.isHidden = true;
            self.audioContainer.isHidden = false;
        }
    }
    
    // On initial view load set VisionOCRView as visible and AudioRecognizeView as hidden
    override func viewDidLoad() {
        super.viewDidLoad()
        self.audioContainer.isHidden = true;
        self.visionContainer.isHidden = false;
    }
}
