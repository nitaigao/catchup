import Foundation

class ContactsTableViewCell: UITableViewCell {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func updateWithModel(model: AnyObject!) {
////        let contact = model as APContact
        self.textLabel?.text? = model as String
    }
    
}
