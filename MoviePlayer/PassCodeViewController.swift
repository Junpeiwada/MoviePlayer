//
//  PassCodeViewController.swift
//  MoviePlayer
//
//  Created by junpeiwada on 2023/06/23.
//  Copyright © 2023 JunpeiWada. All rights reserved.
//

import UIKit
protocol PassCodeViewControllerDelegate: AnyObject {
    func passcodeViewControllerDidSetPasscode(_ controller: PassCodeViewController!)
    func passcodeViewControllerDidEnterPasscode(_ controller: PassCodeViewController!)
}
class PassCodeViewController: UIViewController {
    var delegate:PassCodeViewControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func ok(_ sender: UISwitch) {
        delegate!.passcodeViewControllerDidEnterPasscode(self)
    }

    

}
