//
//  VideoPlayerVC.swift
//  MoviePlayer
//
//  Created by junpeiwada on 2016/08/29.
//  Copyright © 2016年 JunpeiWada. All rights reserved.
//

import Foundation
import AVKit
import AVFoundation
class VideoPlayerVC:  AVPlayerViewController{
    var FilePath:String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = NSURL(fileURLWithPath: self.FilePath)
        let asset = AVURLAsset(url: url as URL)
        let item = AVPlayerItem(asset: asset)
        self.player = AVPlayer(playerItem: item)
        
        self.player!.play()

    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        
        if (UserDefaults.standard.bool(forKey: "Horizontal")){
            let orientation: UIInterfaceOrientationMask = UIInterfaceOrientationMask.landscapeLeft
            return orientation
        }else{
            let orientation: UIInterfaceOrientationMask = UIInterfaceOrientationMask.all
            return orientation
        }
    }
    
    override var shouldAutorotate: Bool{
        return true
    }
    
}
