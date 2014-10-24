import Foundation

class Contact {
  
  var contact : APContact?
  var selected : Bool
  
  init(fromContact abContact:APContact) {
    contact = abContact
    selected = false
  }
}

class ContactsStorage {
  class func isContactSelected(userId:String, contactId:String, completion:(Bool)->Void) {
    var userQuery = PFQuery(className: "User")
    userQuery.getObjectInBackgroundWithId(userId, { (user:PFObject!, error:NSError!) -> Void in
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
    var userQuery = PFQuery(className: "User")
    userQuery.getObjectInBackgroundWithId(userId, block: { (user:PFObject!, error:NSError!) -> Void in
      var contacts = user.relationForKey("contacts")
      var contact = PFObject(className: "Contact")
      contact["contact_id"] = contactId
      contact.saveEventually({ (result:Bool, error:NSError!) -> Void in
        contacts.addObject(contact)
        user.saveEventually()
      })
    })
  }
  
  class func deselectContact(userId:String, contactId:String) {
    var query = PFQuery(className: "User")
    query.getObjectInBackgroundWithId(userId, block: { (result:PFObject!, error:NSError!) -> Void in
      var contacts = result.relationForKey("contacts")
      contacts.query().whereKey("contact_id", equalTo:contactId)
      contacts.query().getFirstObjectInBackgroundWithBlock({ (result:PFObject!, error:NSError!) -> Void in
        result.deleteEventually()
      })
    })
  }
  
  class func mutualContacts(phoneId:String, mutualContactsCompletion:([AnyObject]!) -> Void) {
    var query = PFQuery(className: "Contact")
    query.whereKey("contact_id", equalTo: phoneId)
    query.findObjectsInBackgroundWithBlock { (contactResults:[AnyObject]!, error:NSError!) -> Void in
      contactResults.each { (contactResult:AnyObject) -> () in
        var userQuery = PFQuery(className: "User")
        userQuery.whereKey("contacts", equalTo: contactResult)
        userQuery.getFirstObjectInBackgroundWithBlock({ (userResult:PFObject!, error:NSError!) -> Void in
          let userPhoneId = userResult["phone_id"] as NSString
          
          var userId = NSUserDefaults.standardUserDefaults().objectForKey("user_id") as String
          var userQuery = PFQuery(className: "User")
          userQuery.getObjectInBackgroundWithId(userId, block: { (user:PFObject!, error:NSError!) -> Void in
            var pfContacts = user.relationForKey("contacts")
            
            let addressBook = AddressBook()
            addressBook.findContactsWithPhoneId(userPhoneId, completion: { (contactResults:[APContact]) -> Void in
              var selectedContacts = NSMutableArray()
              contactResults.each { (contactResult:APContact) -> () in
                self.isContactSelected(userId, contactId: userPhoneId, completion: { (isSelected:Bool) -> Void in
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
