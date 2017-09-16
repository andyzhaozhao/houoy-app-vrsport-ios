//
//  FirstViewController.swift
//  SmartHealth
//
//  Created by laoniu on 2017/08/02.
//  Copyright © 2017年 laoniu. All rights reserved.
//

import UIKit

class FindViewController: CommanViewController ,UICollectionViewDataSource, UICollectionViewDelegate , UITableViewDelegate ,UITableViewDataSource{
    var timer: Timer!
    var mArray: Array = [["image":"login_main.jpeg", "title":"标题", "detail":"详细内容"]]
    
    @IBOutlet weak var tableView: UITableView!
    private let refreshControl = UIRefreshControl()
   
    @IBOutlet weak var learningEvent: UIView!
    @IBOutlet weak var sportEvent: UIView!
    @IBOutlet weak var pageController: UIPageControl!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delegate = self;
        self.collectionView.showsHorizontalScrollIndicator = false
        let learningRecognize = UITapGestureRecognizer.init(target: self, action: #selector(FindViewController.learningEventClick))
        learningEvent.addGestureRecognizer(learningRecognize)
        let sportRecognize = UITapGestureRecognizer.init(target: self, action: #selector(FindViewController.sportEventClick))
        sportEvent.addGestureRecognizer(sportRecognize)
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
    
    func learningEventClick() {
        performSegue(withIdentifier: "learningCenter", sender: nil)
    }
    func sportEventClick() {
        performSegue(withIdentifier: "sportCenter", sender: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionViewFlowLayout.itemSize = CGSize(width: self.view.frame.size.width, height: 250)
        collectionViewFlowLayout.minimumInteritemSpacing = 0
        collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionViewFlowLayout.minimumLineSpacing = 0
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        timer = Timer.scheduledTimer(timeInterval: 2.5, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        timer.fire()
    }
    
    func update() {
        //let currentIndex = self.collectionView.indexPathsForVisibleItems
        //let indexPath = IndexPath(item: currentIndex.count + 1, section: 0)
        //self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        // 1.back to the middle of sections
        let currentIndexPath: IndexPath? = self.collectionView.indexPathsForVisibleItems.last
        guard let thecurrentIndexPath = currentIndexPath else {
            return
        }
        // back to the middle of sections
        let currentIndexPathReset = IndexPath(item: thecurrentIndexPath.item, section: 0)
        self.collectionView.scrollToItem(at: currentIndexPathReset, at: .centeredHorizontally, animated: false)
        // 2.next position
        var nextItem: Int = currentIndexPathReset.item + 1
        if nextItem > self.collectionView.numberOfItems(inSection: 0) - 1{
            nextItem = 0
        }
        let nextIndexPath = IndexPath(item: nextItem, section: 0)
        pageController.currentPage = nextItem
        if(nextItem == 0){
            self.collectionView?.scrollToItem(at: nextIndexPath, at: .centeredHorizontally, animated: false)}
        else {

            // 3.scroll to next position
            self.collectionView?.scrollToItem(at: nextIndexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let indexPath = IndexPath(item: 0, section: 0)
        self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        pageController.numberOfPages = self.collectionView.numberOfItems(inSection: 0)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        timer.invalidate()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "find_cell", for: indexPath) as! FindCollectionViewCell
        cell.addImage()
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        let screenW = self.view.frame.width
        
        let offset = offsetX.truncatingRemainder(dividingBy: screenW)
        if(offset < 10){
            let page = offsetX/screenW
            self.pageController.currentPage = Int(page)
        }
    }
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! DetailTableViewCell
        cell.dataDic = mArray[0]
        cell .initUI()
        cell.accessoryType =  UITableViewCellAccessoryType.disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
}

