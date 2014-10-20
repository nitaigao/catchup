import UIKit

class ViewController: UIViewController {
    
    override func viewDidAppear(animated: Bool) {
        super.viewWillAppear(animated)
        var phoneNumber = NSUserDefaults.standardUserDefaults().objectForKey("user_id") as? String
        if nil == phoneNumber {
            self.performSegueWithIdentifier("capture_phone", sender: self)
        }
    }
    
    @IBAction func imAvailable() {
        var userId = NSUserDefaults.standardUserDefaults().objectForKey("user_id") as? String
        var user = PFObject(className: "Contact")
        user["user_id"] = userId
        user["available"] = true
        user.saveEventually()
        self.performSegueWithIdentifier("show_contacts", sender: self)
    }
}

