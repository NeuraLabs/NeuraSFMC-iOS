//
//  ViewController.swift
//  NeuraSFMC
//
//  Created by Rivi Elf on 28/04/2019.
//  Copyright © 2019 Neura. All rights reserved.
//

import UIKit
import NeuraSDK
//import SwiftSVG
import MarketingCloudSDK

class ViewController: UIViewController {
    
    let connectColor    = UIColor(rgb: 0xffffff, alphaVal: 0.2)
    let disconnectColor = UIColor(rgb: 0xffffff, alphaVal: 0.2)
   
    @IBOutlet weak var neuraView: UIView!
    @IBOutlet weak var heartView: UIView!
    @IBOutlet weak var salesforceContainer: UIView!
    @IBOutlet weak var connectBtn: UIButton!
    
    @IBOutlet weak var externalIdLabel: UILabel!
    @IBOutlet weak var externalIdTF: UITextField!
    
    @IBAction func connectAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if NeuraSDK.shared.isAuthenticated(){
            disconnectNeura()
        } else {
            connectToNeura()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        salesforceContainer.createSVGLayer(asset: "salesforce_mc")
        neuraView.createSVGLayer(asset: "neura_logo")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerKeyboradObservers()
        updateUI()
    }
    
    //MARK: Hellper Methoods
    func updateUI(){
        if NeuraSDK.shared.isAuthenticated() {
            externalIdTF.isHidden = true
            externalIdLabel.isHidden = false
            connectBtn.setTitle("Disconnect", for: .normal)
            externalIdLabel.text = NeuraSDK.shared.externalId?.externalIdStr
    
        } else {
            externalIdLabel.isHidden = true
            externalIdTF.isHidden = false
            connectBtn.setTitle("Connect", for: .normal)
        }
    }
    
    
    func setExternalId(){
        guard NeuraSDK.shared.isAuthenticated(),
            let neuraId = NeuraSDK.shared.neuraUserId() else {
            return
        }
        
        var externalIdStr = "sfmc_" + neuraId
        if let externalIdTf = externalIdTF.text, externalIdTf.count > 2 {
            externalIdStr = externalIdTf
        }
       
        let externalId = NExternalId(externalId: externalIdStr)
        guard externalId.isValid else {
            return
        }
        
        NeuraSDK.shared.externalId = externalId
        MarketingCloudSDK.sharedInstance().sfmc_setContactKey(externalIdStr)
    }
    
    
    func connectToNeura(){
        let req = NeuraAnonymousAuthenticationRequest()
        NeuraSDK.shared.authenticate(with: req){ response in
            
            guard response.success else {
                return
            }
            self.setExternalId()
            
            NeuraSDK.shared.requireSubscriptions(toEvents: ["userWokeUp", "userArrivedToWork", "userIsIdleAtHome"], method: .webhook, webhookId: "salesforce")
            DispatchQueue.main.async {
                self.updateUI()
            }
        }
    }
    
    func registerKeyboradObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboradWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboradWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func disconnectNeura(){
        NeuraSDK.shared.logout(callback: { _ in
            DispatchQueue.main.async {
            self.updateUI()
            }
        })
    }
    
    @objc func keyboradWillShow(notification: NSNotification){
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        let keyboardFrame = keyboardSize.cgRectValue
        
        if self.view.frame.origin.y == 0 {
            self.view.frame.origin.y -= keyboardFrame.height
        }
        
    }
    
    @objc func keyboradWillHide(notification: NSNotification){
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }

}


extension UIColor{
    convenience init(rgb: UInt, alphaVal: CGFloat) {
        self.init(
            red:   CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue:  CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: alphaVal
        )
    }
}


