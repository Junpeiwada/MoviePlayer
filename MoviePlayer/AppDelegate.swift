//
//  AppDelegate.swift
//  MoviePlayer
//
//  Created by junpeiwada on 2016/08/29.
//  Copyright © 2016年 JunpeiWada. All rights reserved.
//

import UIKit
//import PAPasscode
//import SVProgressHUD

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate ,PassCodeViewControllerDelegate {

    var window: UIWindow?
    var isPassCodeViewShown = false
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        let usePasscode = UserDefaults.standard.bool(forKey:"useLock")
        if (usePasscode){
            isPassCodeViewShown = true
        }else{
            isPassCodeViewShown = false
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        self.window?.rootViewController?.dismiss(animated: true, completion: nil)
        
        // 黒いビューを表示して、タスクスイッチャに黒い画面が表示されるようにする
        let blankVC = UIViewController.init()
        blankVC.view.backgroundColor = UIColor.black
        self.window?.rootViewController?.present(blankVC, animated: false, completion: nil)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
        let usePasscode = UserDefaults.standard.bool(forKey:"useLock")
        
        if (usePasscode){
            self.isPassCodeViewShown = true
            let passcode = self.loadPassword()
            if (passcode != nil){
                // パスコードの画面を表示する
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let passVC = storyboard.instantiateViewController(withIdentifier: "Passcode") as! PassCodeViewController
                passVC.delegate = self
                
                let navi = UINavigationController.init(rootViewController: passVC)
                
                navi.modalPresentationStyle = UIModalPresentationStyle.fullScreen
                self.window?.rootViewController?.dismiss(animated: false, completion: nil)
                self.window?.rootViewController?.present(navi, animated: false, completion: nil)

            }else{
//                // 新規に設定
//                let passcodeViewController = PAPasscodeViewController.init(for: PasscodeActionSet)
//                passcodeViewController?.delegate = self
//                let navi = UINavigationController.init(rootViewController: passcodeViewController!)
//
//                navi.modalPresentationStyle = UIModalPresentationStyle.fullScreen
//                self.window?.rootViewController?.dismiss(animated: false, completion: nil)
//                self.window?.rootViewController?.present(navi, animated: true, completion: nil)
                
                // パスコードの画面を表示する
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let passVC = storyboard.instantiateViewController(withIdentifier: "Passcode") as! PassCodeViewController
                passVC.delegate = self
                
                let navi = UINavigationController.init(rootViewController: passVC)
                
                navi.modalPresentationStyle = UIModalPresentationStyle.fullScreen
                self.window?.rootViewController?.dismiss(animated: false, completion: nil)
                self.window?.rootViewController?.present(navi, animated: false, completion: nil)
            }
        }else{
            self.window?.rootViewController?.dismiss(animated: false, completion: nil)
        }
    }
    
    func passcodeViewControllerDidSetPasscode(_ controller: PassCodeViewController!) {
//        savePassword(password: controller.passcode)
        self.isPassCodeViewShown = false
        self.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    func passcodeViewControllerDidEnterPasscode(_ controller: PassCodeViewController!) {
        // パスコードが入力された
        self.isPassCodeViewShown = false
        self.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    func savePassword(password : String){
        UserDefaults.standard.setValue(password, forKey: "JPMovieP")
    }
    func loadPassword() -> String? {
        return UserDefaults.standard.object(forKey: "JPMovieP") as! String?
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

