//
//  SettingViewController.swift
//  SmartHealth
//
//  Created by laoniu on 2017/08/05.
//  Copyright © 2017年 laoniu. All rights reserved.
//

import UIKit

class SettingViewController: CommanViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var settingTable: UITableView!
    @IBOutlet weak var versionLabel: UILabel!
    var setArray: Array = ["用户设置","设备设置","帮助和关于","版本更新"]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        versionLabel.text = String.init(format: "%@%@", "V",(Bundle.main.infoDictionary?["CFBundleVersion"]  as? String)!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITable Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("num: \(indexPath.row)")
        if (indexPath.row == 0){
           performSegue(withIdentifier: "settingInfo", sender: nil)
        } else if (indexPath.row == 1){
            performSegue(withIdentifier: "showDeviceSetting", sender: nil)
        } else if (indexPath.row == 2){
            performSegue(withIdentifier: "detail", sender: nil)
        }  else if (indexPath.row == 3){
            UIApplication.shared.open( URL.init(fileURLWithPath: Constants.iTunesLink) , options: [:], completionHandler: nil)
        }
    }
    
    // MARK: - UITable DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return setArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "\(setArray[indexPath.row])"
        return cell
    }
    
    // MARK: - Button Click
    @IBAction func exitBtnClick(_ sender: Any) {
        ApiHelper.loginOut()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.showLoginView()
    }


    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "detail") {
            if let nextViewController = segue.destination as? DetailViewController{
                nextViewController.urlLink = "帮助说明！"
                nextViewController.title = "帮助和关于"
            }
        }
    }


}
