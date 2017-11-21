//
//  SportListViewController.swift
//  SmartHealth
//
//  Created by laoniu on 2017/08/02.
//  Copyright © 2017年 laoniu. All rights reserved.
//

import UIKit
import Alamofire

class SportListViewController: CommanViewController, UITableViewDelegate, UITableViewDataSource,SelectAreaDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    private var videoListModel: SHVideoListModelMap?
    private var videoListNotesModel: [SHVideoresultDataModel]  = []
    private var selectModel: SHVideoresultDataModel?
    private var videPage: Int = 0
    private let refreshControl = UIRefreshControl()
    private var folderModel: SHFolderresultDataModel?
    private var rightButton :UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        self.rightButton = UIButton()
        self.rightButton?.frame = CGRect.init(x: 0, y: 0, width: 100, height: 44)
        self.rightButton?.setTitle("地点选择", for: .normal)
        self.rightButton?.setTitleColor(UIColor.black, for: .normal)
        self.rightButton?.addTarget(self, action: #selector(didTapOnRightButton), for: UIControlEvents.touchUpInside)
        let barButtonItem = UIBarButtonItem(customView: rightButton!)
        self.navigationItem.rightBarButtonItem = barButtonItem
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(MessageViewController.refresh(sender:)), for: .valueChanged)
        self.loadData(folderModel: self.folderModel)
    }
    
    func loadData(folderModel: SHFolderresultDataModel?){
        var parameters: Parameters = [
            Constants.List_Start: videPage,
            Constants.List_Length: Constants.List_Length_Value,
            Constants.List_OrderColumnName: Constants.Video_List_OrderColumnName_Value,
            Constants.List_OrderDir: Constants.List_OrderDir_Desc,
        ]
        
        if (self.folderModel != nil){
            parameters[Constants.List_Pk_Folder] = self.folderModel?.pk_folder
        }
        
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
                    video.downloadTempPath = Utils.getFileMangetr().appendingPathComponent(Constants.Download_Temp + video.video_code! + Constants.Download_File_Divide)
                    video.downloadPath = Utils.getFileMangetr().appendingPathComponent(Constants.Download_Download + video.video_code! + Constants.Download_File_Divide)
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
        self.videoListNotesModel.removeAll()
        self.videPage = 0
        self.loadData(folderModel: self.folderModel)
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    // MARK: - UITable Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = self.videoListNotesModel[indexPath.row]
        self.selectModel = model
        let targetURL = model.downloadPath?.appendingPathComponent(model.video_name)
        if(!FileManager.default.fileExists(atPath: (targetURL?.path)!)){
            let oldSessionTask = DownloadManger.sharedInstance.sessionTaskDictionary[model.video_code!]
            if (oldSessionTask == nil){
                DownloadManger.sharedInstance.startDownloadTask(model: model)
            } else {
                self.view.makeToast("下载中")
            }
        } else {
            performSegue(withIdentifier: "toVRDetail", sender: nil)
        }
    }
    
    // MARK: - UITable DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoListNotesModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SportVideoListCell
        if(indexPath.row > self.videoListNotesModel.count){
            return cell;
        }
            let model = self.videoListNotesModel[indexPath.row]
            model.cell = cell
            cell.initUI(model:model)
            cell.progressView.isHidden = true
            let targetURL =  model.downloadPath!.appendingPathComponent(model.video_name)
            let targetTempURL =  model.downloadTempPath!.appendingPathComponent(model.video_name)
            
            if FileManager.default.fileExists(atPath: targetURL.path) {
                cell.mStatus.text = "已下载"
            } else if FileManager.default.fileExists(atPath: targetTempURL.path) {
                cell.mStatus.text = "继续下载"
            } else{
                cell.mStatus.text = "未下载"
            }
            
            let oldSessionTask = DownloadManger.sharedInstance.sessionTaskDictionary[model.video_code!]
            if (oldSessionTask != nil){
                oldSessionTask?.setModel(model: model)
            }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let theTotal = self.videoListModel?.total else {
            return
        }
        guard let totle = Int(theTotal) else {
            return
        }
        if indexPath.row == self.videoListNotesModel.count - 1 && self.videoListNotesModel.count < totle{
            self.videPage = self.videPage + 1
            self.loadData(folderModel: self.folderModel)
        }
    }
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toVRDetail") {
            if let nextViewController = segue.destination as? VideoPlayerViewController{
                guard let model = self.selectModel else {
                    return
                }
                let targetURL = model.downloadPath?.appendingPathComponent(model.video_name)
                nextViewController.localPath = targetURL?.path;
                nextViewController.modelObject = model
            }
        } else if (segue.identifier == "selectPlace") {
            if let nextViewController = segue.destination as? SportAreaViewController{
                nextViewController.delete = self
            }
        }
    }
    
    //delegate
    func selectWith(model: SHFolderresultDataModel) {
        self.videoListNotesModel.removeAll()
        self.tableView.reloadData()
        self.rightButton?.setTitle(model.folder_name, for: .normal)
        self.folderModel = model
        self.loadData(folderModel: model)
    }
}
