//
//  SVGLayer.swift
//  NeuraSFMC
//
//  Created by Rivi Elf on 29/04/2019.
//  Copyright © 2019 Neura. All rights reserved.
//

import UIKit
import SwiftSVG

extension UIView {
    func createSVGLayer(asset: String){
        guard let asset = NSDataAsset(name: asset) else {
            return
        }
        let _ = CALayer(SVGData: asset.data) { (svgLayer) in
            svgLayer.resizeToFit(self.bounds)
            self.layer.addSublayer(svgLayer)
        }
    }
}
