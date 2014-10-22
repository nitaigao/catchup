import Foundation

class CapturePhoneNumberViewController: UIViewController {
  var delegate : ContactsTableViewController?
  
  @IBOutlet var phoneNumberTextField : UITextField!
  
  @IBAction func saveNumber() {
    var phoneId = (phoneNumberTextField.text as NSString).SHA1()
    var user = PFObject(className: "User")
    user["phone_id"] = phoneId
    user.saveInBackgroundWithBlock { (ok:Bool, error:NSError!) -> Void in
      NSUserDefaults.standardUserDefaults().setObject(user.objectId, forKey:"user_id")
      NSUserDefaults.standardUserDefaults().setObject(phoneId, forKey:"phone_id")
      self.delegate?.refreshData()
      self.dismissViewControllerAnimated(true, completion: { () -> Void in });
    }
  }
}