import Foundation

class ContactsTableViewController: UITableViewController {
  
  let memoryStorage : NSMutableArray = NSMutableArray()
  
  override func viewWillAppear(animated:Bool) {
    super.viewWillAppear(animated)
    self.refreshData()
  }
  
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

    let addressBook = AddressBook()
    addressBook.findAllContactsWithFullNames { (abContacts:[AnyObject]!) -> Void in
      abContacts.each { (abContact:AnyObject) -> Void in
        var contact = Contact(fromContact:abContact as APContact)
        self.memoryStorage.addObject(contact)
        
        if abContacts.last!.isEqual(abContact) {
          dispatch_async(dispatch_get_main_queue()) {
            self.tableView.reloadData()
          }
        }
      }
    }
    
//    var userId = NSUserDefaults.standardUserDefaults().objectForKey("user_id") as? String
//    var userQuery = PFQuery(className: "User")
//    userQuery.getObjectInBackgroundWithId(userId, block: { (user:PFObject!, error:NSError!) -> Void in
//      let addressBook = AddressBook();
//      addressBook.findAllContactsWithFullNames { (abContacts:[AnyObject]!) -> Void in
//        for abContact in abContacts {
//          var contact = Contact(fromContact:abContact as APContact)
//          self.memoryStorage.addObject(contact)
//          let contactId = abContact.phones?.first?.SHA1()
//          ContactsStorage.isContactSelected(userId!, contactId:contactId!, completion: { (result:Bool) -> Void in
//            contact.selected = result
//            if abContacts.last!.isEqual(abContact) {
//              dispatch_async(dispatch_get_main_queue()) {
//                self.tableView.reloadData()
//              }
//            }
//          })
//        }
//      }
//    })
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    var cell = tableView.cellForRowAtIndexPath(indexPath) as ContactsTableViewCell
    
    cell.toggleSelection()
  
    var userId = NSUserDefaults.standardUserDefaults().objectForKey("user_id") as String
    var firstPhone = cell.contact?.contact?.phones.first as String
    
    if cell.contact!.selected {
      ContactsStorage.selectContact(userId, contactId:firstPhone.SHA1())
    } else {
      ContactsStorage.deselectContact(userId, contactId:firstPhone.SHA1())
    }
    
    cell.selected = false
  }
}
