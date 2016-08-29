//
//  ViewController.swift
//  MoviePlayer
//
//  Created by junpeiwada on 2016/08/29.
//  Copyright © 2016年 JunpeiWada. All rights reserved.
//

import UIKit



class ViewController: UITableViewController {
    var filePaths:[String] = []
    var files:[String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        let direcs = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let document = direcs[0]
        do{
            let contents = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(document)
            for item:String in contents{
                print(item)
                files.append(item)
                filePaths.append(document + item)
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
        let l = (cell?.viewWithTag(100) as? UILabel)!
        l.text = files[indexPath.row]
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let player = self.storyboard?.instantiateViewControllerWithIdentifier("Vplayer") as! VideoPlayerVC
        player.FilePath = filePaths[indexPath.row]
        self.navigationController?.pushViewController(player, animated: true)
    }

}

