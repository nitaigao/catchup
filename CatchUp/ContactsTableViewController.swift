import Foundation

class ContactsTableViewController: UITableViewController {
  
  let addressBook = APAddressBook()
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
    
    self.addressBook.fieldsMask = APContactField.Default
    self.addressBook.sortDescriptors = [NSSortDescriptor(key: "firstName", ascending: true),
      NSSortDescriptor(key: "lastName", ascending: true)]
    self.addressBook.filterBlock = {(contact: APContact!) -> Bool in
      return contact.phones.count > 0 && contact.firstName != nil && contact.lastName != nil
    }
    
    var userId = NSUserDefaults.standardUserDefaults().objectForKey("user_id") as? String
    self.addressBook.loadContacts { (abContacts:[AnyObject]!, error:NSError!) -> Void in
      var query = PFQuery(className: "Contact")
      query.whereKey("user_id", equalTo: userId)
      query.findObjectsInBackgroundWithBlock({ (results:[AnyObject]!, error:NSError!) -> Void in
        for abContact in abContacts {
          let contactId = abContact.phones?.first?.SHA1()
          var contact = Contact(fromContact:abContact as APContact)
          
          var isSelected = results.reduce(false, combine: { (m:Bool, result:AnyObject) -> Bool in
            let selectedContact = result as PFObject
            let selectedContactId = selectedContact["contact_id"] as String
            
            if selectedContactId == contactId! {
              return true
            }
            return m
          })
          
          contact.selected = isSelected
          self.memoryStorage.addObject(contact)
        }
        
        dispatch_async(dispatch_get_main_queue()) {
          self.tableView.reloadData ()
        }
      })
    }
  }
  
  override func viewDidLoad() {
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
