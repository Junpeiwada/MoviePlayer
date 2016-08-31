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
        let asset = AVURLAsset(URL: url)
        let item = AVPlayerItem(asset: asset)
        self.player = AVPlayer(playerItem: item)
        
        self.player!.play()

    }
    
    // 向きを横向きにする
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        let orientation: UIInterfaceOrientationMask = UIInterfaceOrientationMask.LandscapeRight
        return orientation
    }
    
    override func shouldAutorotate() -> Bool{
        return true
    }
}