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
        let direcs = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let document = direcs[0]
        
        files.removeAll()
        filePaths.removeAll()
        
        do{
            let contents = try FileManager.default.contentsOfDirectory(atPath:document)
            for item:String in contents{
                files.append(item)
                filePaths.append(document + "/" + item)
            }
        }catch{
            print("ErrorList")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.loadFileList()
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "test")
        let l = (cell?.viewWithTag(1001) as? UILabel)!
        l.text = files[indexPath.row]
        
        
        let imageCount = 10
        var thumbExist = true
        
        // サムネがあるかどうかを調べる
        for i in 0..<imageCount {
            let thumbPath = NSTemporaryDirectory() + "/" + files[indexPath.row] + "-" + i.description
            if (!thumbs.keys.contains(thumbPath)){
                if (!FileManager.default.fileExists(atPath: thumbPath)){
                    thumbExist = false
                }
            }
        }
        
        if (!thumbExist){
            // サムネが存在しないのがあるから、サムネを作る
            print("makeThumbnail")
            
            for i in 0..<imageCount {
                let imageView = (cell?.viewWithTag(10 + i) as? UIImageView)!
                imageView.image = nil
            }
            
            DispatchQueue.global().async {
                let imageView = (cell?.viewWithTag(10) as? UIImageView)!
                self.makeAllThumb(filename: self.files[indexPath.row],filePath: self.filePaths[indexPath.row],rect: imageView.frame)
                DispatchQueue.main.async {
                    tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
                }
            }

        }else{
            for i in 0..<imageCount {
                let thumbPath = NSTemporaryDirectory() + "/" + files[indexPath.row] + "-" + i.description
                let imageView = (cell?.viewWithTag(10 + i) as? UIImageView)!
                if (thumbs.keys.contains(thumbPath)){
                    imageView.image = thumbs[thumbPath]
                }else{
                    DispatchQueue.global().async {
                        let imageFormFile = UIImage(contentsOfFile:thumbPath)
                        DispatchQueue.main.async {
                            imageView.image = imageFormFile
                        }
                    }
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
            
            let image = self.createThumbnail(path: filePath,location:percent,rect:rect)
            
            let dataSaveImagethumb = UIImageJPEGRepresentation(image, 1.0)
            

            do {
                try dataSaveImagethumb?.write(to: URL(fileURLWithPath: makeThumbPath), options: .atomic)
            } catch {
                print(error)
            }
            
            self.thumbs[makeThumbPath] = image
        }
    }
    
    // 再生時刻の割合を指定してサムネイルを作る
    func createThumbnail(path:String,location:Double,rect:CGRect) -> UIImage{
        let url = NSURL(fileURLWithPath:path)
        let asset = AVURLAsset(url: url as URL)
        asset.tracks(withMediaCharacteristic: AVMediaTypeVideo)
        
        let imageGen = AVAssetImageGenerator(asset: asset)
        let durationSeconds = CMTimeGetSeconds(asset.duration)
       
        let midpoint = CMTimeMakeWithSeconds(durationSeconds*location, 600)
        do{
            let hafwatImage = try imageGen.copyCGImage(at: midpoint, actualTime: nil)
            let image = UIImage(cgImage: hafwatImage)
            let miniImage = makeSmallImage(orgImg: image,rect:rect )
            return miniImage
        }catch{
            print("createThumbnailError")
            return UIImage()
        }
    }

    func makeSmallImage(orgImg:UIImage,rect:CGRect) -> UIImage{
        let fitSize = AVMakeRect(aspectRatio: orgImg.size, insideRect: rect)
        let resizedSize = CGSize(width:fitSize.size.width * 2 , height:fitSize.size.height * 2 )
        UIGraphicsBeginImageContext(resizedSize);
        orgImg.draw(in: CGRect(x: 0, y: 0, width: resizedSize.width, height: resizedSize.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return resizedImage!
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let player = self.storyboard?.instantiateViewController(withIdentifier: "Vplayer") as! VideoPlayerVC
        player.FilePath = filePaths[indexPath.row]
        self.present(player, animated: true, completion: nil)
    }

}

