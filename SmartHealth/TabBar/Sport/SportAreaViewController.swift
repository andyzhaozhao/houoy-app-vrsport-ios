//
//  SportAreaViewController.swift
//  SmartHealth
//
//  Created by laoniu on 2017/08/02.
//  Copyright © 2017年 laoniu. All rights reserved.
//

import UIKit
import Alamofire
import Toast_Swift
class SportAreaViewController: CommanViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var mArray: Array = [["image":"login_main.jpeg", "title":"中山公园", "detail":"详细内容"]]
    var mPlaceList :[SHPlaceModel] = []
    
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(MessageViewController.refresh(sender:)), for: .valueChanged)
        self.loadData()
    }
    func loadData(){
        let request = Alamofire.request(Constants.PlaceRetrieve,method: .get, parameters: nil, encoding: JSONEncoding.default,headers: ApiHelper.getDefaultHeader())
        self.view.isUserInteractionEnabled = false
        request.responseJSON { response in
            self.view.isUserInteractionEnabled = true
            switch response.result {
            case .success(let data):
                Utils.printMsg(msg:"JSON: \(data)")
                let dic = data as! NSDictionary
                let resultData = dic[Constants.Place_Retrieve_ResultData_Key] as! NSDictionary
                let notes = resultData[Constants.Place_Retrieve_Nodes_Key] as! NSArray
                for note in notes {
                    let noteDic = note as! NSDictionary
                    let model = SHPlaceModel()
                    model.placeCode = noteDic["place_code"] as! String
                    model.placeCode = noteDic["place_name"] as! String
                    self.mPlaceList.append(model)
                }
            case .failure:
                self.view.makeToast("获取信息失败")
            }
        }
    }
    
    func refresh(sender: UIRefreshControl) {
        refreshControl.beginRefreshing()
        mArray.append(mArray[0])
        tableView.reloadData()
        refreshControl.endRefreshing()
        // ここに通信処理などデータフェッチの処理を書く
        // データフェッチが終わったらUIRefreshControl.endRefreshing()を呼ぶ必要がある
    }
    
    // MARK: - UITable Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        performSegue(withIdentifier: "toEventDetail", sender: nil)
    }
    
    // MARK: - UITable DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! DetailTableViewCell
        cell.dataDic = mArray[indexPath.row]
        cell .initUI()
        //        cell.textLabel?.text = "\(mArray[indexPath.row])"
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == mArray.count - 1 {
            mArray.append(mArray[0])
            tableView.reloadData()
        }
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
