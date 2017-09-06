//
//  AuthenticateViewController.swift
//  ConchIOS
//
//  Created by osx on 2017/7/15.
//  Copyright © 2017年 osx. All rights reserved.
//

import UIKit

class AuthenticateViewController: UIViewController {

    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var authenticateBtn: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    var doneBlock: (() ->Void)?
    
    @IBAction func authenticateBtnTaped(_ sender: Any?) {
        self.messageLabel.text = "正在登录..."
        self.authenticateBtn.isEnabled = false
        self.activityIndicator.startAnimating()
        
        ServiceCenter.authorizationService.authenticate(completion: { [weak self] (success: Bool, error: NSError?) in
            
            guard let _self = self else {
                return
            }
            
            if success {
                _self.doneBlock?()
            }
            else {
                _self.messageLabel.text = error?.localizedDescription
                _self.authenticateBtn.isEnabled = true
                _self.activityIndicator.stopAnimating()
            }
        })
    }
    
    @IBAction func logoutBtnTaped(_ sender: Any?) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.authenticateBtn.layer.borderColor = UIColor.lightGray.cgColor
        self.authenticateBtn.layer.borderWidth = 1
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
