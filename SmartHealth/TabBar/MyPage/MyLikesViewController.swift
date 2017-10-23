//
//  MyLikesViewController.swift
//  SmartHealth
//
//  Created by laoniu on 2017/08/05.
//  Copyright © 2017年 laoniu. All rights reserved.
//

import UIKit

class MyLikesViewController: CommanViewController, UITableViewDelegate, UITableViewDataSource {
//    var dic1: [String: String] = ["image":"login_main.jpeg", "title":"标题", "detail":"详细内容"]
    @IBOutlet weak var tableView: UITableView!
    var mArray: Array = [["image":"login_main.jpeg", "title":"标题", "detail":"详细内容"]]
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(MessageViewController.refresh(sender:)), for: .valueChanged)
    }
    
    func refresh(sender: UIRefreshControl) {
        refreshControl.beginRefreshing()
        mArray.append(mArray[0])
        tableView.reloadData()
        refreshControl.endRefreshing()
        // ここに通信処理などデータフェッチの処理を書く
        // データフェッチが終わったらUIRefreshControl.endRefreshing()を呼ぶ必要がある
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITable Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //performSegue(withIdentifier: "toKnowledgeDetail", sender: nil)
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
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
