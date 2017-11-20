//
//  DeviceSettingViewController.swift
//  SmartHealth
//
//  Created by laoniu on 2017/09/18.
//  Copyright © 2017年 laoniu. All rights reserved.
//

import UIKit

class DeviceSettingViewController: UIViewController , UITableViewDelegate, UITableViewDataSource {
    var setSectionArray: Array = ["支持的VR眼镜","智能手环选择"]
    var setVRArray: Array = ["暴风魔镜","暴风魔镜2代"]
    var setDeviceArray: Array = ["专用手环"]
    @IBOutlet weak var tableView: UITableView!
    
    private var peripheralList : Array<CBPeripheral> = []
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                if let peripheral = HCKPeripheralManager.shared().connectedPeripheral {
                    HCKCentralManager.shared().disconnectConnectedPeripheral()
                    self.view.makeToast("断开连接：\(peripheral.name ?? "")")
                } else {
                    self.view.isUserInteractionEnabled = false
                    self.view.makeToastActivity(CGPoint.init(x: self.view.frame.size.width/2, y: self.view.frame.size.height/2))
                    HCKCentralManager.shared().scanPeripherals(withScanTime: 1, scanPeripheralResultBlock: { (error, peripheralList) in
                        self.view.isUserInteractionEnabled = true
                        if error != nil {
                            self.view.makeToast("请确认蓝牙是否正常开启！")
                            print(error.debugDescription)
                        } else {
                            let alert = UIAlertController.init(title: "", message: "请选择设备", preferredStyle: .actionSheet)
                            if(peripheralList!.count > 0){
                                self.peripheralList = peripheralList as! Array<CBPeripheral>
                                for peripheral in peripheralList! {
                                    let thePeripheral = peripheral as! CBPeripheral
                                    print(thePeripheral.debugDescription)
                                    if(thePeripheral.name != nil) {
                                        alert.addAction(UIAlertAction.init(title: thePeripheral.name , style: .default, handler: self.selectionDevice))
                                    }
                                }
                                alert.addAction(UIAlertAction.init(title: "取消绑定", style: .cancel, handler: { (action: UIAlertAction) in
                                }))
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                        HCKCentralManager.shared().stopScan()
                        self.view.hideToastActivity()
                    })
                }
            }
        }
    }
    
    func selectionDevice(action: UIAlertAction) {
        //Use action.title
        if(self.peripheralList == nil){
            return
        }
        for peripheral in self.peripheralList {
            if(action.title == peripheral.name){
                self.view.makeToastActivity(CGPoint.init(x: self.view.frame.size.width/2, y: self.view.frame.size.height/2))
                self.view.isUserInteractionEnabled = false
                HCKCentralManager.shared().connectPeripheral(withUUID: peripheral.identifier.uuidString, connectSuccessBlock: { (peripheral, uuid, mac) in
                    self.view.makeToast("绑定成功：\(peripheral?.name ?? "")")
                    self.view.isUserInteractionEnabled = true
                    self.view.hideToastActivity()
                }, connectFailedBlock: { (error) in
                    self.view.makeToast("绑定失败！")
                    print(error.debugDescription)
                    self.view.isUserInteractionEnabled = true
                    self.view.hideToastActivity()
                })
                return
            }
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return setSectionArray.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return setSectionArray[section]
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0){
            return setVRArray.count
        } else if (section == 1) {
            return setDeviceArray.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if( indexPath.section == 0){
             cell.textLabel?.text = setVRArray[indexPath.row]
        } else if( indexPath.section == 1){
             cell.textLabel?.text = setDeviceArray[indexPath.row]
        }
       
        cell.accessoryType =  UITableViewCellAccessoryType.disclosureIndicator
        
        //HCKCentralManager.shared().
        return cell
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
