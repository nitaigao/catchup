import Foundation

class ContactsStorage {
  func isContactSelected(userId:String, contactId:String, completion:(Bool)->Void) {
    var userQuery = PFQuery(className: "User")
    userQuery.getObjectInBackgroundWithId(userId, { (user:PFObject!, error:NSError!) -> Void in
      var contactsQuery = user.relationForKey("contacts").query()
      contactsQuery.whereKey("contact_id", equalTo:contactId)
      contactsQuery.getFirstObjectInBackgroundWithBlock({ (result:PFObject!, error:NSError!) -> Void in
        let isSelected : Bool = result != nil
        completion(isSelected)
      })
    })
  }
  
  func selectContact(userId:String, contactId:String) {
    var user = PFQuery.getObjectOfClass("User", objectId: userId)
    var contacts = user.relationForKey("contacts")
    var contact = PFObject(className: "Contact")
    contact["contact_id"] = contactId
    contact.saveEventually({ (result:Bool, error:NSError!) -> Void in
      contacts.addObject(contact)
      user.saveEventually()
    })
  }
  
  func deselectContact(userId:String, contactId:String) {
    var query = PFQuery(className: "User")
    query.getObjectInBackgroundWithId(userId, block: { (result:PFObject!, error:NSError!) -> Void in
      var contacts = result.relationForKey("contacts")
      contacts.query().whereKey("contact_id", equalTo:contactId)
      contacts.query().getFirstObjectInBackgroundWithBlock({ (result:PFObject!, error:NSError!) -> Void in
        result.deleteEventually()
      })
    })
  }
  
  func mutualContacts(phoneId:String, mutualContactsCompletion:([AnyObject]!) -> Void) {
    var query = PFQuery(className: "Contact")
    query.whereKey("contact_id", equalTo: phoneId)
    query.findObjectsInBackgroundWithBlock { (contactResults:[AnyObject]!, error:NSError!) -> Void in
      contactResults.each { (contactResult:AnyObject) -> () in
        var userQuery = PFQuery(className: "User")
        userQuery.whereKey("contacts", equalTo: contactResult)
        userQuery.getFirstObjectInBackgroundWithBlock({ (userResult:PFObject!, error:NSError!) -> Void in
          let userPhoneId = userResult["phone_id"] as NSString
          
          var userId = NSUserDefaults.standardUserDefaults().objectForKey("user_id") as String
          var user = PFQuery.getObjectOfClass("User", objectId: userId)
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
      }
      
    }
  }
}

class ContactsTableViewController: UITableViewController {
  
  let memoryStorage : NSMutableArray = NSMutableArray()
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.memoryStorage.count;
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    var cell = tableView.dequeueReusableCellWithIdentifier("contact_cell") as ContactsTableViewCell
    var contact = self.memoryStorage.objectAtIndex(indexPath.row) as Contact
    cell.updateWithModel(contact)
    return cell;
  }
  
  func refreshData() {
    self.memoryStorage.removeAllObjects()
    
    let contactStorage = ContactsStorage()
    
    var userId = NSUserDefaults.standardUserDefaults().objectForKey("user_id") as? String
    var user = PFQuery.getObjectOfClass("User", objectId: userId)
    
    let addressBook = AddressBook();
    addressBook.findAllContactsWithFullNames { (abContacts:[AnyObject]!) -> Void in
      for abContact in abContacts {
        var contact = Contact(fromContact:abContact as APContact)
        self.memoryStorage.addObject(contact)
        let contactId = abContact.phones?.first?.SHA1()
        contactStorage.isContactSelected(userId!, contactId:contactId!, completion: { (result:Bool) -> Void in
          contact.selected = result
          if abContacts.last!.isEqual(abContact) {
            dispatch_async(dispatch_get_main_queue()) {
              self.tableView.reloadData()
            }
          }
        })
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.refreshData()
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    var userId = NSUserDefaults.standardUserDefaults().objectForKey("user_id") as? String
    if nil == userId {
      self.performSegueWithIdentifier("capture_phone", sender: self)
      return
    }
    
    var query = PFQuery(className: "User")
    query.getObjectInBackgroundWithId(userId, block: { (user:PFObject!, error:NSError!) -> Void in
      if nil == user {
        self.performSegueWithIdentifier("capture_phone", sender: self)
      }
    })
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    let destinationViewController = segue.destinationViewController as CapturePhoneNumberViewController
    destinationViewController.delegate = self
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    var cell = tableView.cellForRowAtIndexPath(indexPath) as ContactsTableViewCell
    
    cell.toggleSelection()
  
    var userId = NSUserDefaults.standardUserDefaults().objectForKey("user_id") as String
    var firstPhone = cell.contact?.contact?.phones.first as String
    
    var contactStorage = ContactsStorage()
    
    if cell.contact!.selected {
      contactStorage.selectContact(userId, contactId:firstPhone.SHA1())
    } else {
      contactStorage.deselectContact(userId, contactId:firstPhone.SHA1())
    }
    
    cell.selected = false
  }
}
