import Foundation

extension Array{
  func each(each: (T) -> ()){
    for object: T in self {
      each(object)
    }
  }
}

class AvailableTableViewController: UITableViewController {
  
  let memoryStorage : NSMutableArray = NSMutableArray()
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.memoryStorage.count;
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    var cell = tableView.dequeueReusableCellWithIdentifier("available_cell") as AvailableTableViewCell
    var contact = self.memoryStorage.objectAtIndex(indexPath.row) as APContact
    let name = contact.firstName + " " + contact.lastName
    cell.updateWithModel(name)
    return cell;
  }
  
  func refreshData() {
    self.memoryStorage.removeAllObjects()
    
    var phoneId = NSUserDefaults.standardUserDefaults().objectForKey("phone_id") as? String

    var query = PFQuery(className: "Contact")
    query.whereKey("contact_id", equalTo: phoneId)
    query.findObjectsInBackgroundWithBlock { (contactResults:[AnyObject]!, error:NSError!) -> Void in
      for contactResult in contactResults {
        
        var userQuery = PFQuery(className: "User")
        userQuery.whereKey("contacts", equalTo: contactResult)
        userQuery.getFirstObjectInBackgroundWithBlock({ (userResult:PFObject!, error:NSError!) -> Void in
          let userPhoneId = userResult["phone_id"] as NSString
          
          var userId = NSUserDefaults.standardUserDefaults().objectForKey("user_id") as String
          var user = PFQuery.getObjectOfClass("User", objectId: userId)
          var pfContacts = user.relationForKey("contacts")
          
          let addressBook = AddressBook()
          addressBook.findContactsWithPhoneId(userPhoneId, completion: { (results:[APContact]) -> Void in
            for result in results {
              let contactStorage = ContactsStorage()
              contactStorage.isContactSelected(userId, contactId: userPhoneId, completion: { (isSelected:Bool) -> Void in
                if isSelected {
                  self.memoryStorage.addObject(result)
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                  self.tableView.reloadData()
                }
              })
            }
          })
        })
      }
      
    }
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    self.refreshData();
  }
}
