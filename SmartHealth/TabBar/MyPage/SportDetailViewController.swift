//
//  SportDetailViewController.swift
//  SmartHealth
//
//  Created by laoniu on 2017/09/18.
//  Copyright © 2017年 laoniu. All rights reserved.
//

import UIKit
import Alamofire
class SportDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    @IBOutlet weak var tableView: UITableView!
    private var listModel: SHLikeRecordHistoryInfoModel?
    private var listNotesModel: [SHLikeRecordHistoryListModel]  = []
    private var listPage: Int = 0
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = false
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(SportDetailViewController.refresh(sender:)), for: .valueChanged)
        let rightButton = UIButton()
        rightButton.frame = CGRect.init(x: 0, y: 0, width: 100, height: 44)
        rightButton.setTitle("选择条件", for: .normal)
        rightButton.setTitleColor(UIColor.black, for: .normal)
        rightButton.addTarget(self, action: #selector(didTapOnRightButton), for: UIControlEvents.touchUpInside)
        let barButtonItem = UIBarButtonItem(customView: rightButton)
        self.navigationItem.rightBarButtonItem = barButtonItem
        self.loadData()
    }
    
    func didTapOnRightButton() {
        performSegue(withIdentifier: "showConditionView", sender: nil)
    }
    
    
    func loadData(){
        let pk = UserDefaults.standard.string(forKey:Constants.Login_User_PK)
        let parameters: Parameters = [
            Constants.List_Start: listPage,
            Constants.List_Length: Constants.List_Length_Value,
            Constants.List_OrderColumnName: Constants.RecordVRSport_List_OrderColumnName_Value,
            Constants.List_OrderDir:Constants.List_OrderDir_Desc,
            Constants.List_User_PK: pk ?? ""
        ]
        let request = Alamofire.request(Constants.RecordVRSportRetrieve,method: .get, parameters: parameters, encoding: URLEncoding.default,headers: ApiHelper.getDefaultHeader())
        self.view.isUserInteractionEnabled = false
        request.responseJSON { response in
            self.view.isUserInteractionEnabled = true
            switch response.result {
            case .success(let data):
                Utils.printMsg(msg:"JSON: \(data)")
                let dic = data as! NSDictionary
                self.listModel = SHLikeRecordHistoryInfoModel(JSON: dic as! [String : Any])
                if let page = self.listModel?.start {
                    self.listPage = page
                }
                let list = self.listModel?.resultData
                guard let theList = list else {
                    return
                }
                for item in theList {
                    self.listNotesModel.append(item)
                }
                self.tableView.reloadData()
            case .failure:
                self.view.makeToast("获取信息失败")
            }
        }
    }
    
    func refresh(sender: UIRefreshControl) {
        refreshControl.beginRefreshing()
        self.loadData()
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    // MARK: - UITable Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        performSegue(withIdentifier: "toEventDetail", sender: nil)
    }
    
    // MARK: - UITable DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listNotesModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MySportListListCell
        cell.initUI(model: self.listNotesModel[indexPath.row])
        cell.tag = indexPath.row
        cell.isUserInteractionEnabled = false
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let theTotal = self.listModel?.total else {
            return
        }
        guard let totle = Int(theTotal) else {
            return
        }
        if indexPath.row == self.listNotesModel.count - 1 && self.listNotesModel.count < totle{
            self.listPage = self.listPage+1
            self.loadData()
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
}
