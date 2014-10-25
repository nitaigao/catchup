import Foundation

class ContactsTableViewCell: UITableViewCell {
  
  var contact : Contact?
  
  func toggleSelection() {
    contact?.selected = !contact!.selected
    self.accessoryType = contact!.selected ? UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None
  }
    
  override func prepareForReuse() {
    self.accessoryType = UITableViewCellAccessoryType.None
  }
  
  func updateWithModel(model: Contact) {
    contact = model
    self.textLabel.text = model.contact!.firstName + " " + model.contact!.lastName
    self.accessoryType = model.selected ? UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None
  }
}
