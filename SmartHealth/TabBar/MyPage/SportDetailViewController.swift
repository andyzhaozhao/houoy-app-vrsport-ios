//
//  SportDetailViewController.swift
//  SmartHealth
//
//  Created by laoniu on 2017/09/18.
//  Copyright © 2017年 laoniu. All rights reserved.
//

import UIKit

class SportDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    @IBOutlet weak var tableView: UITableView!
    var mArray: Array = ["运动历史记录"]
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = false
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(SportDetailViewController.refresh(sender:)), for: .valueChanged)
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - UITable DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = mArray[indexPath.row]
        cell.accessoryType =  UITableViewCellAccessoryType.disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == mArray.count - 1 {
            mArray.append(mArray[0])
            tableView.reloadData()
        }
    }
}
