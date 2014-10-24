import Foundation

class AvailableTableViewController: UITableViewController {
  
  let memoryStorage : NSMutableArray = NSMutableArray()
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.refreshData();
  }
  
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
    
    var phoneId = NSUserDefaults.standardUserDefaults().objectForKey("phone_id") as String
    ContactsStorage.mutualContacts(phoneId, mutualContactsCompletion: { (mutualContacts:[AnyObject]!) -> Void in
      self.memoryStorage.addObjectsFromArray(mutualContacts)
      dispatch_async(dispatch_get_main_queue()) {
        self.tableView.reloadData()
      }
    })
  }
}
