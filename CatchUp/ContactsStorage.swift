import Foundation

class ContactsStorage {
  class func isContactSelected(userId:String, contactId:String, completion:(Bool)->Void) {
    PFUser.query().getObjectInBackgroundWithId(userId, { (user:PFObject!, error:NSError!) -> Void in
      if nil != error {
        completion(false)
        return
      }
      var contactsQuery = user.relationForKey("contacts").query()
      contactsQuery.whereKey("contact_id", equalTo:contactId)
      contactsQuery.getFirstObjectInBackgroundWithBlock({ (result:PFObject!, error:NSError!) -> Void in
        let isSelected : Bool = result != nil
        completion(isSelected)
      })
    })
  }
  
  class func selectContact(userId:String, contactId:String) {
    dispatch_async(dispatch_get_main_queue()) {
      PFUser.query().getObjectInBackgroundWithId(userId, block: { (user:PFObject!, error:NSError!) -> Void in
        var contacts = user.relationForKey("contacts")
        var contact = PFObject(className: "Contact")
        contact["contact_id"] = contactId
        contact.saveInBackgroundWithBlock({ (result:Bool, error:NSError!) -> Void in
          contacts.addObject(contact)
          println(contact)
          println(user)
          user.saveInBackgroundWithBlock({ (result:Bool, error:NSError!) -> Void in
            PFCloud.callFunctionInBackground("catchup_requested", withParameters:["user_id":userId, "contact_id":contactId], block: nil)
          })
        })
      })
    }
  }
  
  class func deselectContact(userId:String, contactId:String) {
    PFUser.query().getObjectInBackgroundWithId(userId, block: { (result:PFObject!, error:NSError!) -> Void in
      var contacts = result.relationForKey("contacts")
      contacts.query().whereKey("contact_id", equalTo:contactId)
      contacts.query().getFirstObjectInBackgroundWithBlock({ (result:PFObject!, error:NSError!) -> Void in
        result.deleteEventually()
      })
    })
  }
  
  class func phoneId(phoneNumber:AnyObject) -> String {
    var numberFormatter = NBPhoneNumberUtil.sharedInstance()
    var normalizedNumber = numberFormatter.normalizePhoneNumber(phoneNumber as String)
    var contactId = Hash.SHA1(normalizedNumber)
    return contactId;
  }
  
  class func mutualContacts(phoneId:String, mutualContactsCompletion:([AnyObject]!) -> Void) {
    var query = PFQuery(className: "Contact")
    query.whereKey("contact_id", equalTo: phoneId)
    query.findObjectsInBackgroundWithBlock { (contactResults:[AnyObject]!, error:NSError!) -> Void in
        if contactResults.count <= 0 || nil != error {
          mutualContactsCompletion([])
          return
        }
        contactResults.each { (contactResult:AnyObject) -> () in
        var userQuery = PFUser.query()
        userQuery.whereKey("contacts", equalTo: contactResult)
        userQuery.getFirstObjectInBackgroundWithBlock({ (userResult:PFObject!, error:NSError!) -> Void in
          if nil != error {
            mutualContactsCompletion([])
            return
          }
          
          let userPhoneId = userResult["username"] as NSString
          
          var userQuery = PFUser.query()
          userQuery.getObjectInBackgroundWithId(Settings.userId, block: { (user:PFObject!, error:NSError!) -> Void in
            if nil != error {
              mutualContactsCompletion([])
              return
            }
            var pfContacts = user.relationForKey("contacts")
            
            let addressBook = AddressBook()
            addressBook.findContactsWithPhoneId(userPhoneId, completion: { (contactResults:[APContact]) -> Void in
              var selectedContacts = NSMutableArray()
              contactResults.each { (contactResult:APContact) -> () in
                self.isContactSelected(Settings.userId, contactId: userPhoneId, completion: { (isSelected:Bool) -> Void in
                  if isSelected {
                    selectedContacts.addObject(contactResult)
                  }
                  
                  if contactResult.isEqual(contactResults.last) {
                    mutualContactsCompletion(selectedContacts)
                  }
                })
              }
            })
          })
        })
      }
      
    }
  }
}

