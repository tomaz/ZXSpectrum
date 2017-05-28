//
//  Created by Tomaz Kragelj on 26.03.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	fileprivate var database = Database()
	fileprivate var persistentContainer: NSPersistentContainer!

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		UserDefaults.establishFactoryDefaults()
		Logger.initialize()
		Defaults.initialize()
		gmarker("INITIALIZED")

		database.createPersistentContainer { container in
			self.persistentContainer = container
			
			guard let storyboard = self.window?.rootViewController?.storyboard else {
				fatalError("Storyboard not available!")
			}
			
			let controller = storyboard.instantiateViewController(withIdentifier: "EmulatorScene")
			self.inject(toController: controller)
			self.window?.rootViewController = controller
		}
		
		return true
	}

	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
		Defaults.isEmulationStarted.value = false
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
		Defaults.isEmulationStarted.value = true
	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}


}

// MARK: - Dependencies

extension AppDelegate: PersistentContainerProvider {
	
	func providePersistentContainer() -> NSPersistentContainer {
		gdebug("Providing \(persistentContainer)")
		return persistentContainer
	}
}
