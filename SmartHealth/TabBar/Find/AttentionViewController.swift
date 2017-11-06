//
//  AttentionViewController.swift
//  SmartHealth
//
//  Created by laoniu on 10/30/17.
//  Copyright © 2017 laoniu. All rights reserved.
//

import UIKit
import Alamofire
class AttentionViewController: CommanViewController, UITableViewDelegate, UITableViewDataSource {
    var type: Int = Constants.Essay_List_Type_32
    @IBOutlet weak var tableView: UITableView!
    private var listModel: SHAttentionInfoModel?
    private var listNotesModel: [SHAttentionListInfoModel]  = []
    private var listPage: Int = 0
    
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(AttentionViewController.refresh(sender:)), for: .valueChanged)
        self.loadData()
    }
    
    func loadData(){
        let parameters: Parameters = [
            Constants.List_Start: listPage,
            Constants.List_Length: Constants.List_Length_Value,
            Constants.List_OrderColumnName: Constants.Attention_List_OrderColumnName_Value,
            Constants.List_OrderDir:Constants.List_OrderDir_Desc
        ]
        let request = Alamofire.request(Constants.RecordShareRetrieve,method: .get, parameters: parameters, encoding: URLEncoding.default,headers: ApiHelper.getDefaultHeader())
        self.view.isUserInteractionEnabled = false
        request.responseJSON { response in
            self.view.isUserInteractionEnabled = true
            switch response.result {
            case .success(let data):
                Utils.printMsg(msg:"JSON: \(data)")
                let dic = data as! NSDictionary
                self.listModel = SHAttentionInfoModel(JSON: dic as! [String : Any])
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FindAttentionListCell
        cell.initUI(model: self.listNotesModel[indexPath.row])
        cell.tag = indexPath.row
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
        if (segue.identifier == "toAttentionDetail") {
            let cell = sender as! UITableViewCell
            if let nextViewController = segue.destination as? FindDetailViewController{
                nextViewController.recordShareModel = self.listNotesModel[cell.tag]
            }
        }
    }
    
    
}

