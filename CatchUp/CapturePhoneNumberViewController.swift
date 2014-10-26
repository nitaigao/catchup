import Foundation

extension String {
  subscript (i: Int) -> String {
    return String(Array(self)[i])
  }
}

class CapturePhoneNumberViewController: UIViewController {
  var delegate : ContactsTableViewController?
  
  @IBOutlet var phoneNumberTextField : UITextField!
  
  @IBAction func saveNumber() {
    var phoneId = ContactsStorage.phoneId(phoneNumberTextField.text)
    
    var installation = PFInstallation.currentInstallation()
    var channelName = "c" + phoneId
    installation.channels = [channelName]
    installation.saveInBackgroundWithBlock(nil)
    
    var user = PFUser()
    user.username = phoneId
    user.password = NSUUID().UUIDString.SHA1()
    user.signUpInBackgroundWithBlock { (ok:Bool, error:NSError!) -> Void in
      Settings.userId = user.objectId
      Settings.phoneId = phoneId
      self.delegate?.refreshData()
      self.dismissViewControllerAnimated(true, completion: { () -> Void in });
    }
  }
}