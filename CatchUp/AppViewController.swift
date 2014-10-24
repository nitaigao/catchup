import Foundation

class AppViewController: UIViewController {
  
  var tabsViewController : UIViewController?

  override func viewDidLoad() {
    super.viewDidLoad()

    var storyboard = UIStoryboard(name:"Main", bundle:nil)
    self.tabsViewController = storyboard.instantiateViewControllerWithIdentifier("app_tabs") as? UIViewController
    self.view.addSubview(self.tabsViewController!.view)
  }
}
