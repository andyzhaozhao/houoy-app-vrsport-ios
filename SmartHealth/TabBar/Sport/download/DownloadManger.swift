//
//  DownloadManger.swift
//  SmartHealth
//
//  Created by laoniu on 11/16/17.
//  Copyright © 2017 laoniu. All rights reserved.
//

import UIKit

class DownloadManger: NSObject {
    
    public var sessionTaskDictionary : Dictionary = Dictionary<String, SHURLSessionDownloadTask>()
    
    class var sharedInstance : DownloadManger {
        struct Static {
            static let instance : DownloadManger = DownloadManger()
        }
        return Static.instance
    }
    
    func startDownloadTask(model:SHVideoresultDataModel) {
        let oldSessionTask = DownloadManger.sharedInstance.sessionTaskDictionary[model.video_code!]
        if (oldSessionTask != nil){
            oldSessionTask?.setModel(model: model)
        } else {
            let sessionTask = SHURLSessionDownloadTask()
            DownloadManger.sharedInstance.sessionTaskDictionary[model.video_code!] = sessionTask
            sessionTask.startSessionDownloadTask(model: model)
        }
    }
}
