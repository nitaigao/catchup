import Foundation

class AddressBook {
  func findContactsWithPhoneId(phoneId:String, completion:([APContact])->Void) {
    let addressBook = APAddressBook()
    addressBook.filterBlock = {(apContact: APContact!) -> Bool in
      return apContact.phones.reduce(false, combine: { (mem:Bool, phone:AnyObject) -> Bool in
        var apContactId = phone.SHA1() as NSString
        if apContactId.isEqualToString(phoneId) {
          return true
        }
        return mem
      })
    }
    
    addressBook.loadContacts { (contacts:[AnyObject]!, error:NSError!) -> Void in
      completion(contacts as [APContact])
    }
  }
  
  func findAllContactsWithFullNames(completion:([AnyObject]!)->Void) {
    let addressBook = APAddressBook()
    addressBook.fieldsMask = APContactField.Default
    addressBook.sortDescriptors = [NSSortDescriptor(key: "firstName", ascending: true), NSSortDescriptor(key: "lastName", ascending: true)]
    addressBook.filterBlock = {(contact: APContact!) -> Bool in
      return contact.phones.count > 0 && contact.firstName != nil && contact.lastName != nil
    }
    addressBook.loadContacts { (contacts:[AnyObject]!, error:NSError!) -> Void in
      completion(contacts)
    }
  }
}
