import UIKit

extension UIViewController {

	/// Returns root view controller.
	static var root: UIViewController {
		return UIApplication.shared.keyWindow!.rootViewController!
	}
	
	/// Returns current view controller.
	static var current: UIViewController {
		return currentViewController(for: UIViewController.root)
	}
	
	private class func viewController<T>(for controller: UIViewController, ofType type: T.Type) -> T? {
		if let result = controller as? T {
			return result ;
		} else if let splitViewController = controller as? UISplitViewController {
			for childController in splitViewController.viewControllers {
				if let result = self.viewController(for: childController, ofType: type) {
					return result
				}
			}
		} else if let tabController = controller as? UITabBarController {
			if let controllers = tabController.viewControllers {
				for childController in controllers {
					if let result = self.viewController(for: childController, ofType: type) {
						return result
					}
				}
			}
		} else if let navigationController = controller as? UINavigationController {
			for childController in navigationController.viewControllers {
				if let result = self.viewController(for: childController, ofType: type) {
					return result
				}
			}
		}
		
		return nil
	}
	
	private class func currentViewController(for controller: UIViewController) -> UIViewController {
		// adapted from http://stackoverflow.com/questions/24825123/get-the-current-view-controller-from-the-app-delegate
		
		if let presentedController = controller.presentedViewController {
			return currentViewController(for: presentedController)
			
		} else if let splitViewController = controller as? UISplitViewController {
			if splitViewController.viewControllers.count > 0 {
				return currentViewController(for: splitViewController.viewControllers[splitViewController.viewControllers.count - 1] as UIViewController)
			}
			
		} else if let navigationController = controller as? UINavigationController {
			if navigationController.viewControllers.count > 0 {
				return currentViewController(for: navigationController.topViewController!)
			}
			
		} else if let tabController = controller as? UITabBarController {
			if let selectedController = tabController.selectedViewController {
				return currentViewController(for: selectedController)
			}
			
		}
		
		return controller
	}
}
