//
//  ViewController.swift
//  SilentWarmth
//
//  Created by guest on 2016/11/10.
//  Copyright © 2016年 chocoffee. All rights reserved.
//

import UIKit
import BubbleTransition
import CoreBluetooth

protocol ViewControllerDelegate {
    func changedEvent(_ data: [[Int]])
}


class ViewController: UIViewController, UIViewControllerTransitioningDelegate, CBCentralManagerDelegate, CBPeripheralDelegate, UIPopoverPresentationControllerDelegate, ViewControllerDelegate {
    @IBOutlet weak var testLabel: UILabel!
    @IBOutlet weak var transitionButton: UIButton!
    @IBOutlet weak var notifyButton: UIButton!
    
    var centralManager: CBCentralManager!
    var discoverPeripheral: CBPeripheral!
    var serviceUUID:[CBUUID] = []
    var ary = [[[Int]]]()
    var advertising = [[Int]]()
    
    //

    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        centralManager.delegate = self
        serviceUUID.append(CBUUID(string: Uuids.serviceUUID))
        _ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: false)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    let transition = BubbleTransition()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SendWarmthViewController {
            vc.vc = self
            return
        }
        let controller = segue.destination
        controller.transitioningDelegate = self
        controller.modalPresentationStyle = .custom
    }
    
    // MARK: UIViewControllerTransitioningDelegate
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .present
        transition.startingPoint = transitionButton.center
        transition.bubbleColor = transitionButton.backgroundColor!
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .dismiss
        transition.startingPoint = transitionButton.center
        transition.bubbleColor = transitionButton.backgroundColor!
        return transition
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("centralState: \(central.state.rawValue)")
    }

    func startScan() {
        centralManager.scanForPeripherals(withServices: serviceUUID, options: nil)
        print("scan start")
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("discover peripheral! ")
        self.discoverPeripheral = peripheral
        self.centralManager.connect(discoverPeripheral, options: nil)
    }
    
    //   ペリフェラルに接続した後
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("connect success")
        discoverPeripheral.delegate = self
        discoverPeripheral.discoverServices(serviceUUID)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("connect failed")
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        let services = peripheral.services
        print("\(services?.count)個のサービスを発見。\(services)")
        
        for obj in services! {
            //  キャラクタリスティック検索開始
            peripheral.discoverCharacteristics(nil, for: obj)   //  obj = CBService
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        let characteristics = service.characteristics
        print("\(characteristics?.count)のキャラクタリスティックを発見。\(characteristics)")
        
        if characteristics != nil {
            for obj in characteristics! {
                if obj.properties == CBCharacteristicProperties.read {
                    peripheral.readValue(for: obj)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.value != nil {
            let value = characteristic.value!
            print("let's reading")
            if let tmpJSON = try? JSONSerialization.jsonObject(with: value, options: .mutableContainers){
                if let json = tmpJSON as? [[Int]]{
                    ary.append(json)
                    print(json)
                }
            }else{
                print("json decode")
            }
        
            if let string = String(data: value, encoding: .utf8){
                print(string)
            }else{
                print("string decode")
            }
        
            print("読み出し成功！service UUID = \(characteristic.service.uuid), characteristic UUID = \(characteristic.uuid), value = \(characteristic.value!)")
        }
    }
        
    func updateCounter() {
        startScan()
    }

    @IBAction func notification(_ sender: UIButton) {
        guard let storyboard = self.storyboard else {
            return
        }
        guard let contentVC = storyboard.instantiateViewController(withIdentifier: "TestViewController") as? TestViewController else{
            return
        }
        //define use of popover
        contentVC.modalPresentationStyle = .popover
        //set size
        contentVC.preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: 300)
        //set origin
        contentVC.popoverPresentationController?.sourceView = view
        contentVC.popoverPresentationController?.sourceRect = sender.frame
        //set arrow direction
        contentVC.popoverPresentationController?.permittedArrowDirections = .up
        //set delegate
        contentVC.popoverPresentationController?.delegate = self
        contentVC.ary = ary
        contentVC.nowAry = advertising
        //present
        present(contentVC, animated: true, completion: nil)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
    func changedEvent(_ data: [[Int]]) {
        advertising = data
        let nowType = Values.type[data[0][0]]
        var who  = ""
        for i in data[1] {
            who.append("\(Values.attribute[i])、")
        }
        let nowColor = Values.color[data[2][0]]
        
        testLabel.text = "\(nowType)\n\(who)\n\(nowColor)\n"
    }


}

