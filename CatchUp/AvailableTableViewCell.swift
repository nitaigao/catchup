import Foundation

class AvailableTableViewCell: UITableViewCell {
  
  func updateWithModel(name:String) {
    self.textLabel.text = name
  }
}
