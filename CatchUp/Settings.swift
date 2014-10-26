import Foundation

class Settings {
  
  class var userId : String {
    get {
      return self.objectForKey("user_id") as String
    }
    set(value) {
      self.setObjectForKey(value, key: "user_id")
    }
  }
  
  class var phoneId : String {
    get {
      return self.objectForKey("phone_id") as String
    }
    set(value) {
      self.setObjectForKey(value, key: "phone_id")
    }
  }

  class func objectForKey(key:String) -> AnyObject? {
    var defaults : NSUserDefaults = NSUserDefaults(suiteName: "group.CatchUp")! as NSUserDefaults
    return defaults.objectForKey(key)
  }
  
  class func setObjectForKey(object:AnyObject?, key:String) -> Void {
    var defaults : NSUserDefaults = NSUserDefaults(suiteName: "group.CatchUp")! as NSUserDefaults
    defaults.setObject(object, forKey: key)
  }

}
