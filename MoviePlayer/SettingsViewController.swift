//
//  SettingsViewController.swift
//  MoviePlayer
//
//  Created by junpeiwada on 2016/10/02.
//  Copyright © 2016年 JunpeiWada. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var rotateSwitch: UISwitch!
    @IBOutlet weak var lockSwitch: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.rotateSwitch.isOn = UserDefaults.standard.bool(forKey: "Horizontal")
        self.lockSwitch.isOn = UserDefaults.standard.bool(forKey: "useLock")
    }
    
    @IBAction func rotateChanged(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "Horizontal")
    }

    @IBAction func clearCache(_ sender: UIButton) {
        self.removeTempImage()
    }

    @IBAction func lockChanged(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "useLock")
    }
    
    func removeTempImage() {
        do{
//            thumbs.removeAll()
            let contents = try FileManager.default.contentsOfDirectory(atPath: NSTemporaryDirectory())
            for item:String in contents{
                try FileManager.default.removeItem(atPath:NSTemporaryDirectory() + "/" + item)
            }
        }catch{
            print("error")
        }
        
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
