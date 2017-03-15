//
//  AppDelegate.swift
//  Dookie
//
//  Created by Mathias Lindholm on 30.01.2017.
//  Copyright © 2017 Mathias Lindholm. All rights reserved.
//

import UIKit
import Firebase
import SwiftyUserDefaults

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var storyboard: UIStoryboard?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
//
//        Defaults.remove(.name)
//        Defaults.remove(.emoji)
//        Defaults.remove(.secret)
//        Defaults.remove(.currentPet)
//        Defaults.remove(.allPets)

        FIRApp.configure()
        FIRDatabase.database().persistenceEnabled = true
        FIRAuth.auth()?.signInAnonymously(completion: { (user, error) in
            if let user = user {
                Defaults[.uid] = user.uid
            }
        })

        self.window?.tintColor = .dookieBlue
        UINavigationBar.appearance().tintColor = .dookieGray
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().isTranslucent = false
        UIToolbar.appearance().setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        UIToolbar.appearance().setShadowImage(UIImage(), forToolbarPosition: .any)
        UIToolbar.appearance().isTranslucent = false

        return true
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if url.scheme == "dookie" {
            guard let host = url.host else { return false }
            if host.isFirebaseUID {
                PetManager.shared.addPet(id: host, name: "", emoji: "")
            }
        }
        return false
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

    func leavePet(animated: Bool) {
        let root = self.window?.rootViewController as! UINavigationController
        if let vc = root.topViewController as? TableViewController {
            vc.activitiesArray.removeAll()
            vc.tableView.reloadData()
        }
        
        self.window?.rootViewController?.dismiss(animated: animated, completion: { _ in
            PetManager.shared.removePet(PetManager.shared.current.id)
            print(Defaults[.currentPet], Defaults[.allPets])
        })
    }

    func deletePet() {
        FIRDatabase.database().reference(withPath: PetManager.shared.current.id).removeValue()
        leavePet(animated: true)
    }
}

