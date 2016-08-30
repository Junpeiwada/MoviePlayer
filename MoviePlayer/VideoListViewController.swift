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
        let direcs = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let document = direcs[0]
        
        print(document)
        
        do{
            let contents = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(document)
            for item:String in contents{
                print(item)
                files.append(item)
                filePaths.append(document + "/" + item)
            }
        }catch{
            
        }
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
        
        let image1 = (cell?.viewWithTag(10) as? UIImageView)!
        image1.image = self.createThumbnail(filePaths[indexPath.row],location: 0.1)
        
        let image2 = (cell?.viewWithTag(11) as? UIImageView)!
        image2.image = self.createThumbnail(filePaths[indexPath.row],location: 0.3)
        
        let image3 = (cell?.viewWithTag(12) as? UIImageView)!
        image3.image = self.createThumbnail(filePaths[indexPath.row],location: 0.6)
        
        let image4 = (cell?.viewWithTag(13) as? UIImageView)!
        image4.image = self.createThumbnail(filePaths[indexPath.row],location: 0.85)
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
            print("Error")
            return UIImage()
        }
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let player = self.storyboard?.instantiateViewControllerWithIdentifier("Vplayer") as! VideoPlayerVC
        player.FilePath = filePaths[indexPath.row]
        self.presentViewController(player, animated: true, completion: nil)
    }

}

