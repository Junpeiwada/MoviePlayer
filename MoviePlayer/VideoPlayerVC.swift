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
        let url = NSURL(fileURLWithPath: self.FilePath)
        let playerItem = AVPlayerItem(URL: url)
        
        let player = AVPlayer(playerItem: playerItem)
        player.play()

    }
}