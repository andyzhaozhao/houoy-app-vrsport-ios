//
//  AppDelegate.swift
//  SmartHealth
//
//  Created by laoniu on 2017/08/02.
//  Copyright © 2017年 laoniu. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Fabric.with([Crashlytics.self])
        HCKCentralManager.shared().scanPeripherals(withScanTime: 1) { (error, list) in
        }
        //TODO resume bug;
        //https://forums.developer.apple.com/thread/92119
        let targetTempURL = Utils.getFileMangetr().appendingPathComponent(Constants.Download_Temp)
        do{
            if FileManager.default.fileExists(atPath: targetTempURL.path) {
                try FileManager.default.removeItem(at: targetTempURL)
            }
        } catch let error as NSError {
            print("download error: \(error)")
        }
        let isSpash = UserDefaults.standard.bool(forKey: Constants.SH_Splash)
        if(!isSpash){
            showView(name: "SHSplashPageViewController")
        } else if (!ApiHelper.isLogin()) {
            self.showLoginView()
        }
        return true
    }

    func showLoginView(){
        self.showView(name: "LoginNavigationController")
    }
    
    func showView(name:String){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController = storyboard.instantiateViewController(withIdentifier: name)
        window?.rootViewController = initialViewController
        //表示
        window?.makeKeyAndVisible()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
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
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask{
        var orientation = UIInterfaceOrientationMask.portrait
        let presented = self.topViewController()
        if let thepresented = presented {
            if thepresented.isKind(of: VideoPlayerViewController.classForCoder())  {
                orientation = thepresented.supportedInterfaceOrientations
            }
        }
        return orientation
    }
    
    func topViewController(base: UIViewController? = (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }

}

