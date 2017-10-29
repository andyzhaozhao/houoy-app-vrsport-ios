//
//  SportListViewController.swift
//  SmartHealth
//
//  Created by laoniu on 2017/08/02.
//  Copyright © 2017年 laoniu. All rights reserved.
//

import UIKit
import Alamofire
class SportListViewController: CommanViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    private var videoListModel: SHVideoListModelMap?
    private var videoListNotesModel: [SHVideoresultDataModel]  = []
    private var videPage: Int = 0
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        let rightButton = UIButton()
        rightButton.frame = CGRect.init(x: 0, y: 0, width: 100, height: 44)
        rightButton.setTitle("选择地点", for: .normal)
        rightButton.setTitleColor(UIColor.black, for: .normal)
        rightButton.addTarget(self, action: #selector(didTapOnRightButton), for: UIControlEvents.touchUpInside)
        let barButtonItem = UIBarButtonItem(customView: rightButton)
        self.navigationItem.rightBarButtonItem = barButtonItem
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(MessageViewController.refresh(sender:)), for: .valueChanged)
        self.loadData()
    }
    
    func loadData(){
        let parameters: Parameters = [
            Constants.Video_List_Start: videPage,
            Constants.Video_List_Length: Constants.Video_List_Length_Value,
            Constants.Video_List_OrderColumnName: Constants.Video_List_OrderColumnName_Value,
            Constants.Video_List_OrderDir: Constants.Video_List_OrderDir_Desc,
        ]
        let request = Alamofire.request(Constants.VideoRetrieve,method: .get, parameters: parameters, encoding: URLEncoding.default,headers: ApiHelper.getDefaultHeader())
        self.view.isUserInteractionEnabled = false
        request.responseJSON { response in
            self.view.isUserInteractionEnabled = true
            switch response.result {
            case .success(let data):
                Utils.printMsg(msg:"JSON: \(data)")
                let dic = data as! NSDictionary
                self.videoListModel = SHVideoListModelMap(JSON: dic as! [String : Any])
                if let page = self.videoListModel?.start {
                     self.videPage = page
                }
                let videoList = self.videoListModel?.resultData
                guard let theVideoList = videoList else {
                    return
                }
                for video in theVideoList {
                    self.videoListNotesModel.append(video)
                }
                self.tableView.reloadData()
            case .failure:
                self.view.makeToast("获取信息失败")
            }
        }
    }
    
    func didTapOnRightButton() {
        performSegue(withIdentifier: "selectPlace", sender: nil)
    }
    
    func refresh(sender: UIRefreshControl) {
        refreshControl.beginRefreshing()
        self.loadData()
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    // MARK: - UITable Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //performSegue(withIdentifier: "toVRDetail", sender: nil)
    }
    
    // MARK: - UITable DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoListNotesModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SportVideoListCell
        cell.initUI(model:self.videoListNotesModel[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == self.videoListNotesModel.count - 1 {
            self.videPage = self.videPage + 1
            self.loadData()
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
