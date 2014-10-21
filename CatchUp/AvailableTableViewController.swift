import Foundation

class AvailableTableViewController: UITableViewController {
  
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
    
    var userId = NSUserDefaults.standardUserDefaults().objectForKey("user_id") as? String
    
    var userQuery = PFQuery(className: "User")
    userQuery.getObjectInBackgroundWithId(userId, block: { (user:PFObject!, error:NSError!) -> Void in
      var phoneId = user["phone_id"] as String
      
      var contactsQuery = PFQuery(className: "User")
      contactsQuery.whereKey("contacts", equalTo: phoneId)
      contactsQuery.findObjectsInBackgroundWithBlock { (contacts:[AnyObject]!, error:NSError!) -> Void in
        for contact in contacts {
          
          
          
        }
      }

    })
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    self.refreshData();
    
  }
}
