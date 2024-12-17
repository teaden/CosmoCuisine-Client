//
//  PhotoPreviewViewController.swift
//  CosmoCuisine-Client
//
//  Created by Tyler Eaden on 12/14/24.
//

import UIKit

protocol PhotoPreviewDelegate {
    func confirmPhoto()
    func retakePhoto()
    func restoreUI()
}

class PhotoPreviewViewController: UIViewController {

    @IBOutlet weak var previewImageView: UIImageView!

    var image: UIImage?
    var recognizedText: String?
    var delegate: PhotoPreviewDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        previewImageView.image = image
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.restoreUI()

        // Your code to be executed before the view disappears
    }

    @IBAction func usePhotoTapped(_ sender: UIButton) {
        delegate?.confirmPhoto()
    }

    @IBAction func retakePhotoTapped(_ sender: UIButton) {
        delegate?.retakePhoto()
    }
}
