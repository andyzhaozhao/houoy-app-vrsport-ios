//
//  FirstViewController.swift
//  SmartHealth
//
//  Created by laoniu on 2017/08/02.
//  Copyright © 2017年 laoniu. All rights reserved.
//

import UIKit

class FindViewController: CommanViewController ,UICollectionViewDataSource, UICollectionViewDelegate{
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delegate = self;
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.scrollViewDidScroll(scrollView: self.collectionView)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 50
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "blue_cell", for: indexPath) as! GLCell
        cell.setIndexPath(indexPath, withCount: 50)
        return cell
    }
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    
    func scrollViewDidScroll(scrollView : UIScrollView) {
        let pointInView = self.view.convert(self.collectionView.center, to: self.collectionView)
        
        let indexPathNow = self.collectionView.indexPathForItem(at: pointInView)
        
        let cell = self.collectionView.cellForItem(at: indexPathNow!)
        
        self.collectionView.bringSubview(toFront: cell!)
    }
    
}

