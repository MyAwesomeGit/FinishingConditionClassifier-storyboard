import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var classifier = FinishingCondition()
    var imagePicker = UIImagePickerController()
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var finishingCondition: UILabel!
    
    @IBAction func cameraTapped(_ sender: Any) {
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func albumTapped(_ sender: Any) {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        if let image = imageView.image {
            finishingConditionClassifier(image: image)
        }
    }

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            imageView.image = image
            finishingConditionClassifier(image: image)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    func finishingConditionClassifier (image: UIImage) {
        if let model = try? VNCoreMLModel(for: classifier.model) {
            let request = VNCoreMLRequest(model: model) { (reqest, error) in
                if let results = reqest.results as? [VNClassificationObservation] {
                    let results = results[0]
                    self.finishingCondition.text = "\(results.identifier), \(String(format: "%.3f", results.confidence)) из 1.00"
                }
            }
            if let imageData = image.jpegData(compressionQuality: 1.0) {
                let handler = VNImageRequestHandler(data:imageData, options: [:])
                try? handler.perform([request])
            }
        }
    }
}
