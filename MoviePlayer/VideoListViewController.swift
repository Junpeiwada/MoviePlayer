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

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func loadFileList(){
        let direcs = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let document = direcs[0]
        
        print(document)
        
        files.removeAll()
        filePaths.removeAll()
        
        do{
            let contents = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(document)
            for item:String in contents{
                print(item)
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
        
        
        
        for i in 0..<7 {
            let thumbPath = NSTemporaryDirectory() + "/" + filePaths[indexPath.row] + "-" + i.description
            let imageView = (cell?.viewWithTag(10 + i) as? UIImageView)!
            if (NSFileManager.defaultManager().fileExistsAtPath(thumbPath)){
                // すでにある
                imageView.image = UIImage(contentsOfFile: thumbPath)
            }else{
                // 無いので作る
                let image = self.createThumbnail(filePaths[indexPath.row],location: 1.0 / 7.0 * Double(i))
                imageView.image = image
                let dataSaveImagethumb = UIImageJPEGRepresentation(image, 1.0)
                
                do{
                    try dataSaveImagethumb?.writeToFile(thumbPath, options: NSDataWritingOptions.DataWritingAtomic)
                }catch{
                    print("dataSaveImagethumbError")
                }
            }
            
        }
        
        return cell!
    }
    
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
    }

}

