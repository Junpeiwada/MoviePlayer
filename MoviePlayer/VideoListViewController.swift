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
        
        
        let imageCount = 8
        
        for i in 0..<imageCount {
            let thumbPath = NSTemporaryDirectory() + "/" + files[indexPath.row] + "-" + i.description
            let imageView = (cell?.viewWithTag(10 + i) as? UIImageView)!
            
            if (thumbs.keys.contains(thumbPath)){
                imageView.image = thumbs[thumbPath]
            }else{
                if (NSFileManager.defaultManager().fileExistsAtPath(thumbPath)){
                    // すでにある
                    imageView.image = UIImage(contentsOfFile:thumbPath)
                }else{
                    imageView.image = nil
                    
                    if (i == 0){
                        print("makeThumbnail")
                        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), {
                            self.makeAllThumb(self.files[indexPath.row],filePath: self.filePaths[indexPath.row])
                            dispatch_sync(dispatch_get_main_queue()) {
                                tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                            }
                        })
                    }
                }
                
            }
        }
        
        return cell!
    }
    
    // 枚数分サムネを作る
    func makeAllThumb(filename:String,filePath:String) {
        let imageCount = 8
        
        // 無いので作る
        for i in 0..<imageCount {
            let makeThumbPath = NSTemporaryDirectory() + "/" + filename + "-" + i.description
            let percent = (1.0 / Double(imageCount + 1)) * Double(i + 1)
            
            let image = self.createThumbnail(filePath,location:percent)
            
            let dataSaveImagethumb = UIImageJPEGRepresentation(image, 1.0)
            
            let res = dataSaveImagethumb?.writeToFile(makeThumbPath, atomically: true)
            if (res == false){
                print("dataSaveImagethumbError")
            }
            
            self.thumbs[makeThumbPath] = image
        }
    }
    
    // 再生時刻の割合を指定してサムネイルを作る
    func createThumbnail(path:String,location:Double) -> UIImage{
        let url = NSURL(fileURLWithPath:path)
        let asset = AVURLAsset(URL: url)
        asset.tracksWithMediaCharacteristic(AVMediaTypeVideo)
        
        let imageGen = AVAssetImageGenerator(asset: asset)
        let durationSeconds = CMTimeGetSeconds(asset.duration)
       
        let midpoint = CMTimeMakeWithSeconds(durationSeconds*location, 600)
        do{
            let hafwatImage = try imageGen.copyCGImageAtTime(midpoint, actualTime: nil)
            let image = UIImage(CGImage: hafwatImage)
            let miniImage = makeSmallImage(image)
            return miniImage
        }catch{
            print("createThumbnailError")
            return UIImage()
        }
    }

    func makeSmallImage(orgImg:UIImage) -> UIImage{
        let resizedSize = CGSizeMake(orgImg.size.width * 0.2,orgImg.size.height * 0.2);
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

