//
//  SportListViewController.swift
//  SmartHealth
//
//  Created by laoniu on 2017/08/02.
//  Copyright © 2017年 laoniu. All rights reserved.
//

import UIKit
import Alamofire
enum DownladStatus: Int {
    case NoDownlaod = 0
    case Downlaoding = 1
    case DownlaodOver = 2
}
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
            parameters[Constants.List_Pk_Folder] = self.folderModel?.folder_code
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
                    let targetURL =  Utils.getFileMangetr().appendingPathComponent(Constants.Download_Download + video.video_name)
                    if FileManager.default.fileExists(atPath: targetURL.path) {
                        video.download = DownladStatus.DownlaodOver
                    } else {
                        // file does not exist
                        video.download = DownladStatus.NoDownlaod
                    }
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
        self.loadData(folderModel: self.folderModel)
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    func downloadVideo(model: SHVideoresultDataModel){
        model.download = DownladStatus.Downlaoding
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let tempURL =  Utils.getFileMangetr().appendingPathComponent(Constants.Download_Temp + model.video_name)
            return (tempURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        //"http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"
        let linkpath = Constants.Download_Base_Link + model.path + Constants.Download_File_Divide + model.video_name
        print(linkpath)
        Alamofire.download(linkpath, to: destination)
            .downloadProgress { (progress) in
                print("Download Progress: \(progress.fractionCompleted)")
                model.download = DownladStatus.Downlaoding
                model.progress = Float(progress.fractionCompleted)
                self.tableView.reloadData()
            }
            .responseData { response in
                switch response.result {
                case .success(_):
                    do {
                        let targetPathURL =  Utils.getFileMangetr().appendingPathComponent(Constants.Download_Download)
                        
                        try FileManager.default.createDirectory(at: targetPathURL, withIntermediateDirectories: true, attributes: nil)
                        
                        if FileManager.default.fileExists(atPath: targetPathURL.appendingPathComponent(model.video_name).path) {
                            try FileManager.default.removeItem(at: targetPathURL.appendingPathComponent(model.video_name))
                        }
                        try! FileManager.default.moveItem(at: response.destinationURL! , to: targetPathURL.appendingPathComponent(model.video_name))
                        
                        self.view.makeToast("视频下载成功", duration: 3.0, position: .center)
                        model.download = DownladStatus.DownlaodOver
                        model.progress = 0
                    } catch {
                        print(error)
                        self.view.makeToast("视频下载失败", duration: 3.0, position: .center)
                        model.download = DownladStatus.NoDownlaod
                    }
                    
                    self.tableView.reloadData()
                case .failure:
                    print("downlaod error")
                    //self.resumeData = response.resumeData
                }
        }
        self.tableView.reloadData()
    }
    
    // MARK: - UITable Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = self.videoListNotesModel[indexPath.row]
        if(model.download == DownladStatus.Downlaoding ){
            return
        }
        self.selectModel = model
        let targetURL =  Utils.getFileMangetr().appendingPathComponent(Constants.Download_Download + model.video_name)
        if(!FileManager.default.fileExists(atPath: targetURL.path)){
            self.downloadVideo(model: model)
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

        let model = self.videoListNotesModel[indexPath.row]
        cell.initUI(model:model)
        if(model.download == DownladStatus.NoDownlaod ){
                cell.mStatus.text = "未下载"
        } else if(model.download == DownladStatus.DownlaodOver ){
                cell.mStatus.text = "已下载"
        } else if(model.download == DownladStatus.Downlaoding ){
                cell.mStatus.text = "正在下载"
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
                let targetURL =  Utils.getFileMangetr().appendingPathComponent(Constants.Download_Download + model.video_name)
                nextViewController.localPath = targetURL.path;
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
        self.rightButton?.setTitle(model.folder_name, for: .normal)
        self.folderModel = model
        self.loadData(folderModel: model)
    }
}
