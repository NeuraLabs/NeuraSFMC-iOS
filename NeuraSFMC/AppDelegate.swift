//
//  AppDelegate.swift
//  NeuraSFMC
//
//  Created by Rivi Elf on 28/04/2019.
//  Copyright © 2019 Neura. All rights reserved.
//

import UIKit
import NeuraSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let marketingCloudSDKManager = MarketingCloudSDKManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        NeuraSDK.shared.setAppUID("[appUID]",
                                  appSecret: "[appSecret]")
      
        DispatchQueue.main.async {
            UIApplication.shared.setMinimumBackgroundFetchInterval(1800)
        }
        
        return marketingCloudSDKManager.launch()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        NeuraSDKPushNotification.registerDeviceToken(deviceToken)
        marketingCloudSDKManager.setDeviceToken(deviceToken: deviceToken)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if NeuraSDKPushNotification.handleNeuraPush(withInfo: userInfo, fetchCompletionHandler: completionHandler) {
            return
        }
        
        marketingCloudSDKManager.receiveRemoteNotification(userInfo: userInfo, fetchCompletionHandler: completionHandler)
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        NeuraSDK.shared.collectDataForBGFetch { result in
            completionHandler(result)
        }
    }
}

