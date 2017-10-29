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


class VideoListViewController: UITableViewController,UIGestureRecognizerDelegate {
    var filePaths:[String] = [] // パスも含めて
    var files:[String] = [] // ファイル名だけ
    var thumbs: Dictionary<String,UIImage> = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(VideoListViewController.cellLongPressed(_:)))
        longPressRecognizer.delegate = self
        tableView.addGestureRecognizer(longPressRecognizer)
    }
    
    // 長押し判定
    @objc func cellLongPressed(_ sender: UITapGestureRecognizer){
        let point = sender.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at:point)
        
        if indexPath != nil {
            if sender.state == UIGestureRecognizerState.began  {
                // 長押しされた場合の処
                print("長押しされたcellのindexPath:\(String(describing: indexPath?.row))")
                
                
                let filename = files[(indexPath?.row)!]
                let filePath = filePaths[(indexPath?.row)!]
                
                let alert = UIAlertController(title: "名前変更", message: "ファイル名を入力", preferredStyle: .alert)
                let saveAction = UIAlertAction(title: "Done", style: .default) { (action:UIAlertAction!) -> Void in
                    
                    // 入力したテキストをコンソールに表示
                    let textField = alert.textFields![0] as UITextField
                    
                    let ns = filePath as NSString
                    let newPath = ns.deletingLastPathComponent + "/" + textField.text! + ".mp4"
                    
                    try! FileManager.default.moveItem(atPath: filePath, toPath: newPath)
                    self.loadFileList()
                    
                    self.tableView.reloadData()
                }
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action:UIAlertAction!) -> Void in
                }
                
                // UIAlertControllerにtextFieldを追加
                alert.addTextField(configurationHandler: {(textField: UITextField!) -> Void in
                    textField.placeholder = filename
                })
                alert.addAction(saveAction)
                alert.addAction(cancelAction)
                
                present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func loadFileList(){
        let direcs = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let document = direcs[0]
        
        files.removeAll()
        filePaths.removeAll()
        
        do{
            let contents = try FileManager.default.contentsOfDirectory(atPath:document)
            for item:String in contents{
                var isDirectory : ObjCBool = false
                FileManager.default.fileExists(atPath: document + "/" + item, isDirectory: &isDirectory)
                if (!isDirectory.boolValue){
                    files.append(item)
                    filePaths.append(document + "/" + item)
                }
            }
            
            files.sort()
            filePaths.sort()
        }catch{
            print("ErrorList")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let app : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        if (app.isPassCodeViewShown){
            self.tableView.isHidden = true
            print("Hide")
        }else{
            self.tableView.isHidden = false
            print("Show")
        }
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
        
        // ファイル名
        let filenameLabel = (cell?.viewWithTag(1001) as? UILabel)!
        filenameLabel.text = files[indexPath.row]
        
        // 時間
        let lengthLabel = (cell?.viewWithTag(1010) as? UILabel)!
        DispatchQueue.global().async {
            let timeString = self.fileDuration(path: self.filePaths[indexPath.row])
            DispatchQueue.main.async {
                lengthLabel.text = timeString
            }
        }
        
        
        let imageCount = 10
        var thumbExist = true
        
        // サムネがあるかどうかを調べる
        for i in 0..<imageCount {
            let thumbPath = self.thumbImagePath(filePath: files[indexPath.row], index: i)
            if (!thumbs.keys.contains(thumbPath)){
                if (!FileManager.default.fileExists(atPath: thumbPath)){
                    thumbExist = false
                }
            }
        }
        
        
        // ぐるぐるをセルから持ってくる
        let activity = (cell?.viewWithTag(100) as? UIActivityIndicatorView)!
        
        
        if (!thumbExist){
            // サムネが存在しないのがあるから、サムネを作る
            print("makeThumbnail")
            
            activity.startAnimating()
            
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
            activity.stopAnimating()
            
            for i in 0..<imageCount {
                let thumbPath = self.thumbImagePath(filePath: files[indexPath.row], index: i)
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
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        // 削除ボタンをだす
        let deleteButton: UITableViewRowAction = UITableViewRowAction(style: .normal, title: "削除"){ (action, index) -> Void in
            
            let targetPath = self.filePaths[indexPath.row]
            do {
                  try FileManager.default.removeItem(atPath: targetPath)
            }catch{
                print("削除に失敗")
                return
            }
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        deleteButton.backgroundColor = UIColor.red
        
        return [deleteButton]
    }

    
    
    // 枚数分サムネを作る
    func makeAllThumb(filename:String,filePath:String,rect:CGRect) {
        let imageCount = 10
        
        // 無いので作る
        for i in 0..<imageCount {
            let makeThumbPath = self.thumbImagePath(filePath: filename, index: i)
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
    
    // 指定されたパスの動画の長さをいい感じの文字列にして返す
    func fileDuration(path:String) -> String{
        let url = NSURL(fileURLWithPath:path)
        let asset = AVURLAsset(url: url as URL)
        
        let videoDurationSeconds = CMTimeGetSeconds(asset.duration)
        
        let dHours = Int(floor(videoDurationSeconds / 3600))
        let dMinutes = Int(floor(videoDurationSeconds.truncatingRemainder(dividingBy: 3600) / 60))
        let dSeconds = Int(floor(videoDurationSeconds.truncatingRemainder(dividingBy: 3600).truncatingRemainder(dividingBy: 60)))
        
        
        if (dHours > 0){
            let str = String(format:"%02d:%02d:%02d", dHours, dMinutes, dSeconds)
            return str
        }else{
            let str = String(format:"%02d:%02d", dMinutes, dSeconds)
            return str
        }
        
        
    }
    
    // 再生時刻の割合を指定してサムネイルを作る
    func createThumbnail(path:String,location:Double,rect:CGRect) -> UIImage{
        let url = NSURL(fileURLWithPath:path)
        let asset = AVURLAsset(url: url as URL)

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
    
    func thumbImagePath(filePath:String,index:Int)-> String{
        let direcs = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let document = direcs[0]
        let thumbPath = document + "/thumb/" + filePath + "-" + index.description
        if (!FileManager.default.fileExists(atPath: document + "/thumb")){
            do {
                try FileManager.default.createDirectory(atPath: document + "/thumb", withIntermediateDirectories: false, attributes: nil)
            }catch{
                print("サムネディレクトリの生成に失敗")
            }
        }
        return thumbPath
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

