import Foundation

class BootViewController: UIViewController {
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    var userId = Settings.objectForKey("user_id") as? String
    var phoneId = Settings.objectForKey("phone_id") as? String
    
    if nil == userId || nil == phoneId {
      self.performSegueWithIdentifier("capture_phone", sender: self)
      return
    }
    
  
    PFUser.query().getObjectInBackgroundWithId(userId, block: { (user:PFObject!, error:NSError!) -> Void in
      if nil == user {
        self.performSegueWithIdentifier("capture_phone", sender: self)
        return
      }
      else {
        self.performSegueWithIdentifier("show_app", sender: self)
      }
    })
  }
}