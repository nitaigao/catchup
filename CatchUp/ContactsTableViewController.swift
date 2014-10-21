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
      return contact.phones.count > 0
    }
    
    var userId = NSUserDefaults.standardUserDefaults().objectForKey("user_id") as? String
    self.addressBook.loadContacts { (abContacts:[AnyObject]!, error:NSError!) -> Void in
      var query = PFQuery(className: "User")
      query.getObjectInBackgroundWithId(userId, block: { (user:PFObject!, error:NSError!) -> Void in
        var selectedContacts = user["contacts"] as [String]
        
        for abContact in abContacts {
          var contact = Contact(fromContact:abContact as APContact)
          self.memoryStorage.addObject(contact)

          let contactId = abContact.phones?.first?.SHA1()
          
          var isSelected = selectedContacts.reduce(false, combine: { (m:Bool, selectedContact:String) -> Bool in
            if selectedContact == contactId! {
              return true
            }
            return m
          })
          
          contact.selected = isSelected

        }
        dispatch_async(dispatch_get_main_queue()) {
          self.tableView.reloadData()
        }
      })
    }
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
      else {
        dispatch_async(dispatch_get_main_queue()) {
          self.refreshData()
        }
      }
    })
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    let destinationViewController = segue.destinationViewController as CapturePhoneNumberViewController
    destinationViewController.delegate = self
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    var cell = tableView.cellForRowAtIndexPath(indexPath) as ContactsTableViewCell
    
    if cell.accessoryType == UITableViewCellAccessoryType.Checkmark {
      cell.accessoryType = UITableViewCellAccessoryType.None
      
      var userId = NSUserDefaults.standardUserDefaults().objectForKey("user_id") as? String
      var query = PFQuery(className: "User")
      query.getObjectInBackgroundWithId(userId, block: { (user:PFObject!, error:NSError!) -> Void in
        var contacts = user["contacts"] as NSMutableArray
        var phone = cell.contact?.phones.first as String
        contacts.removeObject(phone.SHA1())
        
        user.saveInBackgroundWithBlock({ (ok:Bool, error:NSError!) -> Void in
//          var cloud = PFCloud()
//          var parameters = NSDictionary()
//          cloud.callFunctionInBackground("push", withParameters:parameters)
        })
      })

    } else {
      cell.accessoryType = UITableViewCellAccessoryType.Checkmark
      
      var userId = NSUserDefaults.standardUserDefaults().objectForKey("user_id") as? String
      var query = PFQuery(className: "User")
      query.getObjectInBackgroundWithId(userId, block: { (user:PFObject!, error:NSError!) -> Void in
        var contacts = user["contacts"] as NSMutableArray
        var phone = cell.contact?.phones.first as String
        contacts.addObject(phone.SHA1())
        user.saveEventually()
      })
    }
    
    cell.selected = false
  }
}
