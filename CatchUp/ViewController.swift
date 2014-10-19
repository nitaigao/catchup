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
        
    }
}

