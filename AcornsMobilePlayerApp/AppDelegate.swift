//
//  AppDelegate.swift
//  AcornsMobilePlayerApp
//
//  Created by Dan Harvey on 7/23/15.
//  Copyright (c) 2015 Dan Harvey. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
        navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        splitViewController.delegate = self
        splitViewController.preferredDisplayMode = .primaryOverlay
         
        if let URL = launchOptions?[UIApplication.LaunchOptionsKey.url] as? URL {
            
            // If we get here, we know launchOptions is not nil, we know
            // UIApplicationLaunchOptionsURLKey was in the launchOptions
            // dictionary, and we know that the type of the launchOptions
            // was correctly identified as NSURL.  At this point, URL has
            // the type NSURL and is ready to use.
            let filePath : String = URL.path
            NSLog("Normal startup = %@", filePath)
        }
          return true
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
 
        // Determine who sent the URL.
                                                                                  if #available(iOS 9.0, *) {
            let sendingAppID = options[.sourceApplication]
            print("source application = \(sendingAppID ?? "Unknown")")
        } else {
            print ("none")
        }
 
        if #available(iOS 9.0, *) {
            let isOpenInPlace = options[.openInPlace] as? Bool
            print (isOpenInPlace as Any)
        } else {
            print ("no open in place")
        }
        
        let urlPath = url.absoluteURL
        let text = urlPath
        print(text)        
        
        let lessons = AcornsLessons()
        lessons.copyLesson(text)
        
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        let navigationController = splitViewController.viewControllers[0] as! UINavigationController
        let master = navigationController.viewControllers[0] as! MasterViewController
        master.reloadView()
        return true;
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        NSLog("Application openurl")
        
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        let navigationController = splitViewController.viewControllers[0] as! UINavigationController
        let master = navigationController.viewControllers[0] as! MasterViewController
        master.reloadView()
        return true;
   }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: - Split view

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
        if let secondaryAsNavController = secondaryViewController as? UINavigationController {
            if let topAsDetailController = secondaryAsNavController.topViewController as? DetailViewController {
                if topAsDetailController.detailItem == nil {
                    // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
                    return true
                }
            }
        }
        return false
    }
    
}

