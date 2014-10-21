import Foundation

class ContactsTableViewCell: UITableViewCell {
  
  var contact : APContact?
  
  func updateWithModel(model: Contact) {
    contact = model.contact!
    self.textLabel?.text = model.contact!.firstName + " " + model.contact!.lastName
    self.accessoryType = model.selected ? UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None
  }
}
