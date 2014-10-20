import Foundation

class ContactsTableViewController: UITableViewController {
    
    let memoryStorage : NSMutableArray = NSMutableArray()
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.memoryStorage.count;
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("ContactsTableViewCell") as ContactsTableViewCell
        var model : AnyObject = self.memoryStorage.objectAtIndex(indexPath.row)
        cell.updateWithModel(model)
        
        return cell;
    }
    
    let addressBook = APAddressBook()
    
    override func viewDidAppear(animated:Bool) {
        super.viewDidAppear(animated)
        
        self.addressBook.fieldsMask = APContactField.Default
        
        self.addressBook.loadContacts { (contacts:[AnyObject]!, error:NSError!) -> Void in
            var allContacts = contacts.reduce(NSMutableArray(), combine: { (m:NSMutableArray, contactElement:AnyObject) -> NSMutableArray in
                var contact = contactElement as APContact
                for phone in contact.phones {
                    var contactId = phone.SHA1()
                    m.addObject(contactId)
                }
                return m
            })
            
            for contact in allContacts {
                var query = PFQuery(className: "Contact")
                query.whereKey("user_id", equalTo: contact)
                query.findObjectsInBackgroundWithBlock({ (results:[AnyObject]!, error:NSError!) -> Void in
                    for result in results {
                        var isAvailable = result["available"] as Bool
                        if isAvailable {
                            var contactString = result["user_id"] as NSString
                            for contactElement in contacts {
                                var contact = contactElement as APContact
                                for phone in contact.phones {
                                    var contactId = phone.SHA1()
                                    if contactId == contactString {
                                        
                                        self.memoryStorage.addObject(contact.firstName + " " + contact.lastName)
                                    }
                                }
                            }
                        }
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tableView.reloadData()
                    }
                })
            }
        }
    }
}
