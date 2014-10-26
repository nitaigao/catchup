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
  
  func phoneId(phoneNumber:AnyObject) -> String {
    var numberFormatter = NBPhoneNumberUtil.sharedInstance()
    var normalizedNumber = numberFormatter.normalizePhoneNumber(phoneNumber as String)
    var contactId = Hash.SHA1(normalizedNumber)
    return contactId;
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

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
              var phoneId = self.phoneId(number)
              var kDefaultsPackage = "group.CatchUp"
              var defaults : NSUserDefaults = NSUserDefaults(suiteName: kDefaultsPackage)!
              var userId : NSString = defaults.objectForKey("user_id") as NSString
              println(userId)
            }
          })
          break
        }
      }
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @IBAction func done() {
    // Return any edited content to the host app.
    // This template doesn't do anything, so we just echo the passed in items.
    self.extensionContext!.completeRequestReturningItems(self.extensionContext!.inputItems, completionHandler: nil)
  }

}
