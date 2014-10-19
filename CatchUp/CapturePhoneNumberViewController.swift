import Foundation

class CapturePhoneNumberViewController: UIViewController {

    @IBOutlet var phoneNumberTextField : UITextField!
    
    @IBAction func saveNumber() {
        
        var userId = (phoneNumberTextField.text as NSString).SHA1()
        
        NSUserDefaults.standardUserDefaults().setObject(userId, forKey:"user_id")
        
        let addressBook = APAddressBook()
        addressBook.loadContacts { (contacts:[AnyObject]!, error:NSError!) -> Void in
            var allContacts = contacts.reduce(NSMutableArray(), combine: { (m:NSMutableArray, contactElement:AnyObject) -> NSMutableArray in
                var contact = contactElement as APContact
                for phone in contact.phones {
                    var contactId = phone.SHA1()
                    m.addObject(contactId)
                }
                return m
            })
            
            var user = PFObject(className: "AppUser")
            user["user_id"] = userId
            user["contacts"] = allContacts
            user.saveEventually()
        }
        
        self.dismissViewControllerAnimated(true, completion: { () -> Void in });
    }
    
}