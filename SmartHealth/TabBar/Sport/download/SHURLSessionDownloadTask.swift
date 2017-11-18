//
//  SHURLSessionDownloadTask.swift
//  SmartHealth
//
//  Created by laoniu on 11/18/17.
//  Copyright © 2017 laoniu. All rights reserved.
//

import UIKit

class SHURLSessionDownloadTask: NSObject,URLSessionDelegate, URLSessionDataDelegate {

    var vodeiModel:SHVideoresultDataModel?
    
    func setModel(model:SHVideoresultDataModel){
        model.downloadSize = (self.vodeiModel?.downloadSize)!
        model.fileSize = (self.vodeiModel?.fileSize)!
        model.sessionTask = (self.vodeiModel?.sessionTask)!
        let progress = ((self.vodeiModel?.downloadSize)! / (self.vodeiModel?.fileSize)!)
        model.cell?.progressView.setProgress(Float(progress), animated: false)
        model.cell?.progressView.isHidden = false
        self.vodeiModel = model
    }
    
    func startSessionDownloadTask(model:SHVideoresultDataModel) {
        self.vodeiModel = model
        self.vodeiModel?.sessionTask = self
        let sessionConfig = URLSessionConfiguration.default;
        sessionConfig.urlCache = nil
        sessionConfig.requestCachePolicy = .reloadIgnoringLocalCacheData
        let session = URLSession.init(configuration: sessionConfig, delegate: self, delegateQueue: nil)
        
        let linkpath = Constants.Download_Base_Link + vodeiModel!.path + Constants.Download_File_Divide + vodeiModel!.video_name
        let url = URL(string: linkpath)!
        var request = URLRequest.init(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 60)
//        var request = URLRequest.init(url: url)
//        request.setValue("zh-CN" , forHTTPHeaderField:"Accept-Language");
//        request.setValue("UTF-8" , forHTTPHeaderField:"Charset");
//        request.setValue("keep-live" , forHTTPHeaderField:"Connection");
//        request.setValue("300" , forHTTPHeaderField:"Keep-Alive");
        var downloadSize:CLongLong  = 0
        do {
            let fileTempPath = vodeiModel!.downloadTempPath!.appendingPathComponent(vodeiModel!.video_name)
            if(FileManager.default.fileExists(atPath: fileTempPath.path)){
                
                let cache = URLCache.shared.cachedResponse(for: request)
                print(cache.debugDescription)
                
                URLCache.shared.removeCachedResponse(for: request)
                // Set headers
                let data = try Data(contentsOf: fileTempPath)
                downloadSize = CLongLong(data.count)
                request.setValue("bytes＝\(downloadSize)-" , forHTTPHeaderField:"Range");
                self.vodeiModel?.cell?.mStatus.text = "继续下载"
            } else {
                try FileManager.default.createDirectory(at: vodeiModel!.downloadTempPath!, withIntermediateDirectories: true, attributes: nil)
                FileManager.default.createFile(atPath: fileTempPath.path, contents: nil, attributes: nil)
            }
            self.vodeiModel?.downloadSize = downloadSize
            let dataTask = session.dataTask(with: request)
            dataTask.resume()
        } catch let error as NSError {
            print("download error: \(error)")
            DownloadManger.sharedInstance.sessionTaskDictionary.removeValue(forKey: (self.vodeiModel?.video_code)!)
            model.sessionTask = nil
        }
    }
    
    // MARK: - URLSessionDataDelegate
    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        // We've got a URLAuthenticationChallenge - we simply trust the HTTPS server and we proceed
        print("didReceive challenge")
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        // We've got the response headers from the server.
        print("didReceive response")
        let model = self.vodeiModel!
        let httpResponse = response as! HTTPURLResponse
        let length = (httpResponse.allHeaderFields["Content-Length"] as! NSString).longLongValue
        model.fileSize = (model.downloadSize) + length
        DispatchQueue.main.async(execute: {
            model.cell?.mStatus.text = "准备下载"
            let progress = ((model.downloadSize) / (model.fileSize))
            model.cell?.progressView.setProgress(Float(progress), animated: false)
            model.cell?.progressView.isHidden = false
        })
        completionHandler(URLSession.ResponseDisposition.allow)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse, completionHandler: @escaping (CachedURLResponse?) -> Void) {
        completionHandler(nil)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print("didReceive didComplete")
        // We've got an error
        if let err = error {
            print("Error: \(err.localizedDescription)")
        } else {
            do {
                let fileTempPath = vodeiModel!.downloadTempPath!.appendingPathComponent(vodeiModel!.video_name)
                let filePath = vodeiModel!.downloadPath!.appendingPathComponent(vodeiModel!.video_name)
                try FileManager.default.createDirectory(at: vodeiModel!.downloadPath!, withIntermediateDirectories: true, attributes: nil)
                if FileManager.default.fileExists(atPath: filePath.path) {
                    try FileManager.default.removeItem(at: filePath)
                }
                try! FileManager.default.moveItem(at: fileTempPath , to: filePath)
                DispatchQueue.main.async(execute: {
                    self.vodeiModel?.cell?.mStatus.text = "已下载"
                    self.vodeiModel?.cell?.progressView.isHidden = true
                })
            } catch let error as NSError {
                print("download error: \(error)")
            }
        }
        DownloadManger.sharedInstance.sessionTaskDictionary.removeValue(forKey: (self.vodeiModel?.video_code)!)
        vodeiModel?.sessionTask = nil
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        // We've got the response body
        do {
            let fileTempPath = vodeiModel!.downloadTempPath!.appendingPathComponent(vodeiModel!.video_name)
            var oldData = try Data(contentsOf: fileTempPath)
            oldData.append(data)
            try oldData.write(to: fileTempPath, options: .noFileProtection)
            self.vodeiModel?.downloadSize = CLongLong(oldData.count)
            DispatchQueue.main.async(execute: {
                self.vodeiModel?.cell?.mStatus.text = "下载中"
                let progress = ((self.vodeiModel?.downloadSize)! / (self.vodeiModel?.fileSize)!)
                self.vodeiModel?.cell?.progressView.setProgress(Float(progress), animated: false)
            })
        } catch let error as NSError {
            print("download error: \(error)")
            DownloadManger.sharedInstance.sessionTaskDictionary.removeValue(forKey: (self.vodeiModel?.video_code)!)
            vodeiModel?.sessionTask = nil
        }
    }
    
}
