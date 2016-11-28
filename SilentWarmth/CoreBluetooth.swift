//
//  CoreBluetooth.swift
//  SilentWarmth
//
//  Created by guest on 2016/11/18.
//  Copyright © 2016年 chocoffee. All rights reserved.
//

import Foundation
import CoreBluetooth

class CoreBluetooth: CBCentralManagerDelegate, CBPeripheralManagerDelegate, CBPeripheralDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("centralState: \(central.state)")
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print("peripheralState: \(peripheral.state)")
    }
    
    
}
