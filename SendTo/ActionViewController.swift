import UIKit
import MobileCoreServices

class ActionViewController: UIViewController {

  func phoneNumbers(record:ABRecord!) -> NSArray {
    var results = NSMutableArray()
    var phoneNumbers : ABMultiValueRef = ABRecordCopyValue(record, kABPersonPhoneProperty).takeRetainedValue();
    for (var i : CFIndex = 0; i < ABMultiValueGetCount(phoneNumbers); i++) {
      var number : NSString = ABMultiValueCopyValueAtIndex(phoneNumbers,i).takeRetainedValue() as NSString
      results.addObject(number)
    }
    return results
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    Parse.setApplicationId("m2lzGhNQcPev2ivKqfRRVr4ZP12k0LDP79FzMkTl", clientKey:"E9GdH2RRXh1k88SnjtRiEl6tCbfcTshi5MFsVAgw")

    for item: AnyObject in self.extensionContext!.inputItems {
      let inputItem = item as NSExtensionItem
      for provider: AnyObject in inputItem.attachments! {
        let itemProvider = provider as NSItemProvider
        if itemProvider.hasItemConformingToTypeIdentifier(kUTTypeContact as NSString) {
          itemProvider.loadItemForTypeIdentifier(kUTTypeContact as NSString, options: nil, completionHandler: { (vCard, error) in
            let vCardData = vCard as? NSData
            var addressBookRecord : ABRecordRef = vCardSerialization.addressBookRecordsWithVCardData(vCardData, error: nil).first!
            var numbers = self.phoneNumbers(addressBookRecord)
            for number in numbers {
              var phoneId = ContactsStorage.phoneId(number)
              ContactsStorage.selectContact(Settings.userId, contactId: phoneId)
              break
            }
          })
          break
        }
      }
    }
  }

  @IBAction func done() {
    self.extensionContext!.completeRequestReturningItems(self.extensionContext!.inputItems, completionHandler: nil)
  }

}
