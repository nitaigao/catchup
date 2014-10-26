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
    
    User.query().getObjectInBackgroundWithId(Settings.userId, block: { (userResult:PFObject!, error:NSError!) -> Void in
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
                var apContactPhoneId = ContactsStorage.phoneId(apContactPhone)
                var isSelected = apContactPhoneId == (contactResultContactId as NSString)
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
  
    var firstPhone = cell.contact?.contact?.phones.first as String
    var contactId = ContactsStorage.phoneId(firstPhone)
    
    if cell.contact!.selected {
      ContactsStorage.selectContact(Settings.userId, contactId:contactId)
    } else {
      ContactsStorage.deselectContact(Settings.userId, contactId:contactId)
    }
    
    cell.selected = false
  }
}
