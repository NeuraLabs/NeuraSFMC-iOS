//
//  MarketingCloudSDKManager.swift
//  NeuraSFMC
//
//  Created by Rivi Elf on 28/04/2019.
//  Copyright © 2019 Neura. All rights reserved.
//

import Foundation
import MarketingCloudSDK

class MarketingCloudSDKManager: NSObject {
    let MCSdk = MarketingCloudSDK.sharedInstance()
    
    func launch() -> Bool{
        var error: NSError?
        let success: Bool = MCSdk.sfmc_configure(&error)
        guard success else {
            return false
        }
        MCSdk.sfmc_setDebugLoggingEnabled(true)
        requestAuthorization()
        return success
    }
    
    func setDeviceToken(deviceToken: Data) {
         MCSdk.sfmc_setDeviceToken(deviceToken)
    }
    
    func requestAuthorization(){
        DispatchQueue.main.async {
            if #available(iOS 10.0, *) {
                UNUserNotificationCenter.current().delegate = self
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {(_ granted: Bool, _ error: Error?) -> Void in
                    if error == nil && granted {
                        DispatchQueue.main.async {
                            UIApplication.shared.registerForRemoteNotifications()
                        }
                    }
                })
            } else {
                let type: UIUserNotificationType = [UIUserNotificationType.badge, UIUserNotificationType.alert, UIUserNotificationType.sound]
                let setting = UIUserNotificationSettings(types: type, categories: nil)
                UIApplication.shared.registerUserNotificationSettings(setting)
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func receiveRemoteNotification(userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void){
            let theSilentPushContent = UNMutableNotificationContent()
       
        theSilentPushContent.userInfo = userInfo
        let theSilentPushRequest = UNNotificationRequest(identifier:UUID().uuidString, content: theSilentPushContent, trigger: nil)
        MCSdk.sfmc_setNotificationRequest(theSilentPushRequest)
        
        completionHandler(.newData)
    }
}

extension MarketingCloudSDKManager: UNUserNotificationCenterDelegate {
 
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        MCSdk.sfmc_setNotificationRequest(response.notification.request)
        
        completionHandler()
    }
}
