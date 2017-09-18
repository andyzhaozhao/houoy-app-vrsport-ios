//
//  DeviceSettingViewController.swift
//  SmartHealth
//
//  Created by laoniu on 2017/09/18.
//  Copyright © 2017年 laoniu. All rights reserved.
//

import UIKit

class DeviceSettingViewController: UIViewController , UITableViewDelegate, UITableViewDataSource {
    var setSectionArray: Array = ["VR眼睛选择","智能手环选择"]
    var setVRArray: Array = ["暴风小D","暴风魔镜2代"]
    var setDeviceArray: Array = ["小米手环","专用手环"]
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
