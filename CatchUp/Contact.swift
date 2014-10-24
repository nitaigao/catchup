import Foundation

class Contact : PFObject, PFSubclassing {
  
  class func parseClassName() -> String! {
    return "Contact"
  }
  
  var contact : APContact?
  var selected : Bool
  
  init(fromContact abContact:APContact) {
    contact = abContact
    selected = false
    super.init()
  }
}