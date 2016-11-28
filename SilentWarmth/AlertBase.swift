//
//  AlertBase.swift
//  SilentWarmth
//
//  Created by guest on 2016/11/17.
//  Copyright © 2016年 chocoffee. All rights reserved.
//

import Foundation
import UIKit
import SCLAlertView

class AleatBase : SCLAlertView{
    let icon = UIImage(named: "twitter.jpg")
    let appearance = SCLAlertView.SCLAppearance(showCloseButton: false)
    
    func alert(_ btn1: String, btn2: String, title: String, subTitle: String, advertise: @escaping () -> (Void)) {
        let alert = SCLAlertView(appearance: appearance)
        _ = alert.addButton(btn1, backgroundColor: UIColor.red, textColor: UIColor.white, showDurationStatus: true, action: advertise)
        
        _ = alert.addButton(btn2, backgroundColor: UIColor.red, textColor: UIColor.white, showDurationStatus: true) {}
        
        _ = alert.showCustom(title, subTitle: subTitle, color: UIColor.red, icon: icon!)
    }
    
    func alert(_ btn1: String, title: String, subTitle: String) {
        let alert = SCLAlertView(appearance: appearance)
        _ = alert.addButton(btn1, backgroundColor: UIColor.red, textColor: UIColor.white, showDurationStatus: true){
            print("custom button")
        }
        _ = alert.showCustom(title, subTitle: subTitle, color: UIColor.red, icon: icon!)
        
    }
}
