import Foundation

class Contact {
  
  var contact : APContact?
  var selected : Bool
  
  init(fromContact abContact:APContact) {
    contact = abContact
    selected = false
  }
}
