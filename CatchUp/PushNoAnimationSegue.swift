import Foundation

class PushNoAnimationSegue: UIStoryboardSegue {
  override func perform() {
    let sourceController = self.sourceViewController as UIViewController
    let destinationController = self.destinationViewController as UIViewController
    
    sourceController.presentViewController(destinationController, animated: false, completion: nil)
  }
}
