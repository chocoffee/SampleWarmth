//
//  MurmurViewController.swift
//  SilentWarmth
//
//  Created by guest on 2016/11/14.
//  Copyright © 2016年 chocoffee. All rights reserved.
//

import UIKit
import CoreBluetooth

class MurmurViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, CBPeripheralDelegate, CBPeripheralManagerDelegate {

    @IBOutlet weak var messagePicker: UIPickerView!
    @IBOutlet weak var colorPicker: UIPickerView!
    
    let alert = AleatBase()
    var advertiseData = [[]]
    
    var peripheral: CBPeripheral!
    var peripheralManager: CBPeripheralManager!
    var characteristic: CBMutableCharacteristic!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        messagePicker.delegate = self
        messagePicker.dataSource = self
        colorPicker.delegate = self
        colorPicker.dataSource = self
        self.title = "周囲に発信する"
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 {
            return Values.message.count
        }else {
            return Values.color.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
            return Values.message[row]
        }else {
            return Values.color[row]
        }
    }
    
    @IBAction func sendMessage(_ sender: UIButton) {
        let messageIndex = messagePicker.selectedRow(inComponent: 0)
        let colorIndex = colorPicker.selectedRow(inComponent: 0)
        var str = ""
        self.advertiseData = [[2], [messageIndex], [colorIndex]]
        str.append("\(Values.message[messageIndex]),\n\(Values.color[colorIndex])")
        
        setAlert(str)
    }
    
    func setAlert(_ str: String) {
        alert.alert("発信する！", btn2: "キャンセル", title: "確認", subTitle: str, advertise: advertise)
    }

    func advertise() {
        guard let json = try? JSONSerialization.data(withJSONObject: advertiseData, options: .init(rawValue: 0)) else{
            return
        }
        let serviceUUID = CBUUID(string: Uuids.serviceUUID)
        let service = CBMutableService(type: serviceUUID, primary: true)
        let charactericUUID = CBUUID(string: Uuids.characteristicUUID)
        characteristic = CBMutableCharacteristic(type: charactericUUID, properties: CBCharacteristicProperties.read, value: json, permissions: CBAttributePermissions.readable)
        service.characteristics = [characteristic]
        self.peripheralManager.add(service)
        
        let advertisementData = [CBAdvertisementDataServiceUUIDsKey:[service.uuid]] as [String : Any]
        peripheralManager.startAdvertising(advertisementData)
        
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print("state: \(peripheral.state)")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if error != nil {
            print("service add failed...")
            return
        }
        print("service add success!")
    }
    
    //  advertise result
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if error != nil {
            print("advertising error...")
            return
        }
        print("advertising success!")
    }
}
