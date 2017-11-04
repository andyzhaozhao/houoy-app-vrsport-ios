//
//  SHSplashPageViewController.swift
//  SmartHealth
//
//  Created by RUIQIANG(瑞強) LIU(劉) on 11/4/17.
//  Copyright © 2017 laoniu. All rights reserved.
//

import UIKit

class SHSplashPageViewController: UIPageViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.setViewControllers([getFirst()], direction: .forward, animated: true, completion: nil)
    }
    
    func getFirst() -> FirstViewController {
        return storyboard!.instantiateViewController(withIdentifier:"FirstViewController") as! FirstViewController
    }

    func getSecond() -> SecondViewController {
        return storyboard!.instantiateViewController(withIdentifier:"SecondViewController") as! SecondViewController
    }
    
    func getThird() -> ThirdViewController {
        return storyboard!.instantiateViewController(withIdentifier:"ThirdViewController") as! ThirdViewController
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

}

extension SHSplashPageViewController : UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if viewController.isKind(of:ThirdViewController.self) {
            // 3 -> 2
            return getSecond()
        } else if viewController.isKind(of:SecondViewController.self) {
            // 2 -> 1
            return getFirst()
        } else {
            // 1 -> end of the road
            return nil
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if viewController.isKind(of:FirstViewController.self) {
            // 1 -> 2
            return getSecond()
        } else if viewController.isKind(of:SecondViewController.self) {
            // 2 -> 3
            return getThird()
        } else {
            // 3 -> end of the road
            return nil
        }
    }
}

