//
//  ViewController.swift
//  FlowerClassifier
//
//  Created by Philip Tam on 2018-04-27.
//  Copyright © 2018 TheAwesomeMonster. All rights reserved.
//

import UIKit
import CoreML
import Vision

class CameraController: UIViewController {

    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    
    let picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        picker.sourceType = .camera
        picker.allowsEditing = true
        picker.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func cameraButtonPressed(_ sender: Any) {
        present(picker, animated: true, completion: nil)
    }
    
    func identifyFlower(_ image: CIImage){
        
        guard let model = try? VNCoreMLModel.init(for: FlowerClassifier().model) else {fatalError("Loading CoreML model failed")}
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {fatalError("Model failed to process image")}
            
            if let flower = results.first?.identifier.capitalized{

                self.navigationItem.title = flower
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do{
            try handler.perform([request])
        }catch{
            print(error)
        }
        
    }
}

extension CameraController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage{
            imageView.image = image
            
            guard let ciImage = CIImage(image: image) else {fatalError("Could not convert to CiImage")}
            
            identifyFlower(ciImage)
        }
        dismiss(animated: true, completion: nil)
    }
}
