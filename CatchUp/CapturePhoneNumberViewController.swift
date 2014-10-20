import Foundation

class CapturePhoneNumberViewController: UIViewController {

    @IBOutlet var phoneNumberTextField : UITextField!
    
    @IBAction func saveNumber() {
        var userId = (phoneNumberTextField.text as NSString).SHA1()
        NSUserDefaults.standardUserDefaults().setObject(userId, forKey:"user_id")
        self.dismissViewControllerAnimated(true, completion: { () -> Void in });
    }
}