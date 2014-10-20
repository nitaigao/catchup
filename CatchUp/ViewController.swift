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
        var phoneNumber = NSUserDefaults.standardUserDefaults().objectForKey("user_id") as? String
        var query = PFQuery(className: "AppUser")
        query.whereKey("contacts", equalTo: phoneNumber)
        query.findObjectsInBackgroundWithBlock { (results:[AnyObject]!, error:NSError!) -> Void in
            if error != nil { println(error) }
            for result in results {
                println(result)
            }
        }
    }
}

