//
//  ViewController.swift
//  MoviePlayer
//
//  Created by junpeiwada on 2016/08/29.
//  Copyright © 2016年 JunpeiWada. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation


class VideoListViewController: UITableViewController {
    var filePaths:[String] = []
    var files:[String] = []
    var thumbs: Dictionary<String,UIImage> = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func loadFileList(){
        let direcs = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let document = direcs[0]
        
        files.removeAll()
        filePaths.removeAll()
        
        do{
            let contents = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(document)
            for item:String in contents{
                files.append(item)
                filePaths.append(document + "/" + item)
            }
        }catch{
            print("ErrorList")
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.loadFileList()
        self.tableView.reloadData()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("test")
        let l = (cell?.viewWithTag(1001) as? UILabel)!
        l.text = files[indexPath.row]
        
        
        let imageCount = 10
        var thumbExist = true
        
        // サムネがあるかどうかを調べる
        for i in 0..<imageCount {
            let thumbPath = NSTemporaryDirectory() + "/" + files[indexPath.row] + "-" + i.description
            if (!thumbs.keys.contains(thumbPath)){
                if (!NSFileManager.defaultManager().fileExistsAtPath(thumbPath)){
                    thumbExist = false
                }
            }
        }
        
        if (!thumbExist){
            // サムネが存在しないのがあるから、サムネを作る
            print("makeThumbnail")
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), {
                let imageView = (cell?.viewWithTag(10) as? UIImageView)!
                self.makeAllThumb(self.files[indexPath.row],filePath: self.filePaths[indexPath.row],rect: imageView.frame)
                dispatch_async(dispatch_get_main_queue()) {
                    tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                }
            })
        }else{
            for i in 0..<imageCount {
                let thumbPath = NSTemporaryDirectory() + "/" + files[indexPath.row] + "-" + i.description
                let imageView = (cell?.viewWithTag(10 + i) as? UIImageView)!
                if (thumbs.keys.contains(thumbPath)){
                    imageView.image = thumbs[thumbPath]
                }else{
                    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), {
                        let imageFormFile = UIImage(contentsOfFile:thumbPath)
                        dispatch_async(dispatch_get_main_queue()) {
                            imageView.image = imageFormFile
                        }
                    })
                }
            }
        }
        return cell!
    }
    
    
    
    // 枚数分サムネを作る
    func makeAllThumb(filename:String,filePath:String,rect:CGRect) {
        let imageCount = 10
        
        // 無いので作る
        for i in 0..<imageCount {
            let makeThumbPath = NSTemporaryDirectory() + "/" + filename + "-" + i.description
            let percent = (1.0 / Double(imageCount + 1)) * Double(i + 1)
            
            let image = self.createThumbnail(filePath,location:percent,rect:rect)
            
            let dataSaveImagethumb = UIImageJPEGRepresentation(image, 1.0)
            
            let res = dataSaveImagethumb?.writeToFile(makeThumbPath, atomically: true)
            if (res == false){
                print("dataSaveImagethumbError")
            }
            
            self.thumbs[makeThumbPath] = image
        }
    }
    
    // 再生時刻の割合を指定してサムネイルを作る
    func createThumbnail(path:String,location:Double,rect:CGRect) -> UIImage{
        let url = NSURL(fileURLWithPath:path)
        let asset = AVURLAsset(URL: url)
        asset.tracksWithMediaCharacteristic(AVMediaTypeVideo)
        
        let imageGen = AVAssetImageGenerator(asset: asset)
        let durationSeconds = CMTimeGetSeconds(asset.duration)
       
        let midpoint = CMTimeMakeWithSeconds(durationSeconds*location, 600)
        do{
            let hafwatImage = try imageGen.copyCGImageAtTime(midpoint, actualTime: nil)
            let image = UIImage(CGImage: hafwatImage)
            let miniImage = makeSmallImage(image,rect:rect )
            return miniImage
        }catch{
            print("createThumbnailError")
            return UIImage()
        }
    }

    func makeSmallImage(orgImg:UIImage,rect:CGRect) -> UIImage{
        let fitSize = AVMakeRectWithAspectRatioInsideRect(orgImg.size, rect)
        let resizedSize = CGSizeMake(fitSize.size.width * 2 , fitSize.size.height * 2 )
        UIGraphicsBeginImageContext(resizedSize);
        orgImg.drawInRect(CGRectMake(0, 0, resizedSize.width, resizedSize.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return resizedImage
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let player = self.storyboard?.instantiateViewControllerWithIdentifier("Vplayer") as! VideoPlayerVC
        player.FilePath = filePaths[indexPath.row]
        self.presentViewController(player, animated: true, completion: nil)
    }

    func removeTempImage() {
        do{
            thumbs.removeAll()
            let contents = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(NSTemporaryDirectory())
            for item:String in contents{
                try NSFileManager.defaultManager().removeItemAtPath(NSTemporaryDirectory() + "/" + item)
            }
        }catch{
            print("error")
        }
        

    }
    
    @IBAction func clearTemp(sender: AnyObject) {
        self.removeTempImage()
        self.tableView.reloadData()
    }
}

