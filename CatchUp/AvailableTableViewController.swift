import Foundation

class AvailableTableViewController: UITableViewController {
  
  let memoryStorage : NSMutableArray = NSMutableArray()

  var emptyViewController : UIViewController?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    var storyboard = UIStoryboard(name:"Main", bundle:nil)
    self.emptyViewController = storyboard.instantiateViewControllerWithIdentifier("available_empty") as? UIViewController

    NSNotificationCenter.defaultCenter().addObserver(self, selector:"appCameToForeground:", name:UIApplicationWillEnterForegroundNotification, object:nil);
    NSNotificationCenter.defaultCenter().addObserver(self, selector:"receivedContactNotification:", name:"received_contact_notification", object:nil);
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.refreshData()
  }
  
  func receivedContactNotification(notification: NSNotification) {
    self.refreshData()
  }
  
  func appCameToForeground(notification: NSNotification) {
    self.refreshData()
  }
  
  func refreshData() {
    ContactsStorage.mutualContacts(Settings.phoneId, mutualContactsCompletion: { (mutualContacts:[AnyObject]!) -> Void in
      dispatch_async(dispatch_get_main_queue()) {
        self.memoryStorage.removeAllObjects()
        self.memoryStorage.addObjectsFromArray(mutualContacts)
        self.tableView.reloadData()
      }
    })
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let count = self.memoryStorage.count;
    if count <= 0 {
      self.view.addSubview(self.emptyViewController!.view)
    } else {
      self.emptyViewController!.view.removeFromSuperview()
    }
    return count;
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    var cell = tableView.dequeueReusableCellWithIdentifier("available_cell") as AvailableTableViewCell
    var contact = self.memoryStorage.objectAtIndex(indexPath.row) as APContact
    let name = contact.firstName + " " + contact.lastName
    cell.updateWithModel(name)
    return cell;
  }
  
//  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//    var contact = self.memoryStorage.objectAtIndex(indexPath.row) as APContact
//    var personViewController = ABPersonViewController()
//    personViewController.displayedPerson = contact
//    self.presentViewController(personViewController, animated: true, completion: nil)
//  }
  
}
