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
protocol SelectAreaDelegate {
    func selectWith(palaceid : String , placeName: String)
}

class SportAreaViewController: CommanViewController, UITableViewDelegate, UITableViewDataSource {
    var delete:SelectAreaDelegate?
    @IBOutlet weak var tableView: UITableView!
    var placeModel: SHPlaceModelMap?
    var placeNotesModel: [SHPlaceresultDataModel]  = []
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
                self.placeModel = SHPlaceModelMap(JSON: dic as! [String : Any])
                let nodes = self.placeModel?.resultData?.nodes
                guard let theNodes = nodes else {
                    return
                }
                self.getNodesList(nodes: theNodes)
                self.tableView.reloadData()
            case .failure:
                self.view.makeToast("获取信息失败")
            }
        }
    }
    
    func getNodesList(nodes : [SHPlaceresultDataModel]?){
        guard let theNodes = nodes else {
            return
        }
        for node in theNodes {
            if (node.nodes.count == 0){
                self.placeNotesModel.append(node)
            } else {
                getNodesList(nodes: node.nodes)
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
        let alert: UIAlertController = UIAlertController(title: "确认", message: "确定添加这个地点？", preferredStyle: UIAlertControllerStyle.alert)
        let defaultAction: UIAlertAction = UIAlertAction(title: "确认", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
            self.delete?.selectWith(palaceid: "id", placeName: "name")
            self.navigationController?.popViewController(animated: true)
        })
        let cancelAction: UIAlertAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
            
        })
        alert.addAction(defaultAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - UITable DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.placeNotesModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SportPlaceCell
        cell .initUI(model: self.placeNotesModel[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == self.placeNotesModel.count - 1 {
            //FIXME add pagenumber.
            //self.loadData()
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
