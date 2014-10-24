import Foundation

class ContactsTableViewController: UITableViewController {
  
  let memoryStorage : NSMutableArray = NSMutableArray()
  
  override func viewDidLoad() {
    super.viewDidLoad()
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
    
    var userId = NSUserDefaults.standardUserDefaults().objectForKey("user_id") as? String
    
    User.query().getObjectInBackgroundWithId(userId, block: { (userResult:PFObject!, error:NSError!) -> Void in
      var contactsQuery = userResult.relationForKey("contacts").query()
      contactsQuery.findObjectsInBackgroundWithBlock({ (contactsResults:[AnyObject]!, error:NSError!) -> Void in
        
        let addressBook = AddressBook()
        addressBook.findAllContactsWithFullNames { (abContacts:[AnyObject]!) -> Void in
          abContacts.each { (abContact:AnyObject) -> Void in
            var contact = Contact(fromContact:abContact as APContact)
            self.memoryStorage.addObject(contact)
            
            var isSelected = contactsResults.reduce(false, combine: { (mem:Bool, contactResult:AnyObject) -> Bool in
              let contactResultContactId = contactResult["contact_id"]
              var isSelected = abContact.phones!.reduce(false, combine: { (mem:Bool, apContactPhone:AnyObject!) -> Bool in
                var isSelected = (apContactPhone as NSString).SHA1() == (contactResultContactId as NSString)
                if isSelected {
                  return true
                }
                return mem
              })
              
              if isSelected {
                return true
              }
              return mem
            })
            
            contact.selected = isSelected
            
            if abContacts.last!.isEqual(abContact) {
              dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
              }
            }
          }
        }
      })
    })
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
