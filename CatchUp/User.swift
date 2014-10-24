import Foundation

class User : PFObject, PFSubclassing {
  
  class func parseClassName() -> String! {
    return "User"
  }
  
}