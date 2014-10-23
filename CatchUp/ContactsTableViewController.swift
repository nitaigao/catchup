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
  
    var userId = NSUserDefaults.standardUserDefaults().objectForKey("user_id") as? String
    
    if cell.contact!.selected {
      var user = PFQuery.getObjectOfClass("User", objectId: userId)
      var contacts = user.relationForKey("contacts")
      var contact = PFObject(className: "Contact")
      var phone = cell.contact?.contact?.phones.first as String
      contact["contact_id"] = phone.SHA1()
      contact.saveEventually({ (result:Bool, error:NSError!) -> Void in
        contacts.addObject(contact)
        user.saveEventually()
      })
    } else {
      var query = PFQuery(className: "User")
      query.getObjectInBackgroundWithId(userId, block: { (result:PFObject!, error:NSError!) -> Void in
        var contacts = result.relationForKey("contacts")
        var phone  = cell.contact?.contact?.phones.first as String
        contacts.query().whereKey("contact_id", equalTo:phone.SHA1())
        contacts.query().getFirstObjectInBackgroundWithBlock({ (result:PFObject!, error:NSError!) -> Void in
          result.deleteEventually()
        })
      })
    }
    
    cell.selected = false
  }
}
