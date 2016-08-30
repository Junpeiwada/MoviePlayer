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
        
        
        
        for i in 0..<8 {
            let thumbPath = NSTemporaryDirectory() + "/" + files[indexPath.row] + "-" + i.description
            let imageView = (cell?.viewWithTag(10 + i) as? UIImageView)!
            
            if (thumbs.keys.contains(thumbPath)){
                imageView.image = thumbs[thumbPath]
            }else{
                if (NSFileManager.defaultManager().fileExistsAtPath(thumbPath)){
                    // すでにある
                    imageView.image = UIImage(contentsOfFile:thumbPath)
                }else{
                    // 無いので作る
                    let image = self.createThumbnail(self.filePaths[indexPath.row],location: 1.0 / (8.0 + 1) * Double(i + 1))
                    imageView.image = image
                    let dataSaveImagethumb = UIImageJPEGRepresentation(image, 1.0)
                    
                    let res = dataSaveImagethumb?.writeToFile(thumbPath, atomically: true)
                    if (res == false){
                        print("dataSaveImagethumbError")
                    }
                }
                self.thumbs[thumbPath] = imageView.image
            }
        }
        
        return cell!
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
            return image
        }catch{
            print("createThumbnailError")
            return UIImage()
        }
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let player = self.storyboard?.instantiateViewControllerWithIdentifier("Vplayer") as! VideoPlayerVC
        player.FilePath = filePaths[indexPath.row]
        self.presentViewController(player, animated: true, completion: nil)
        removeTempImage()
    }

    func removeTempImage() {
        do{
            let contents = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(NSTemporaryDirectory())
            for item:String in contents{
                try NSFileManager.defaultManager().removeItemAtPath(NSTemporaryDirectory() + "/" + item)
            }
        }catch{
            print("error")
        }
        

    }
}

