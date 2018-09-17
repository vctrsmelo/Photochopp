import UIKit

class SelectImageViewController: UIViewController {
    
    let myPickerController = UIImagePickerController()
    
    @IBAction func didTouchPickImage(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            myPickerController.delegate = self
            myPickerController.sourceType = .photoLibrary
            self.present(myPickerController, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMainViewController" {
            guard let image = sender as? UIImage, let vc = segue.destination as? MainViewController else { return }
            vc.configure(image)
        }
    }
}

extension SelectImageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage]
            as? UIImage {
            myPickerController.dismiss(animated: true, completion: nil)
            performSegue(withIdentifier: "showMainViewController", sender: image)
        }
    }
}
