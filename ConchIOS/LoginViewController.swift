//
//  LoginViewController.swift
//  ConchIOS
//
//  Created by osx on 2017/7/14.
//  Copyright © 2017年 osx. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    // MARK: 属性
    var doneHandler: (() ->Void)?
    
    // MARK: - 控件
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var pwdField: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var messageLabel: UILabel!
    
    // MARK: - 事件
    @IBAction func loginBtnTapped(_ sender: Any?) {
        self.loginBtn.isEnabled = false
        self.userNameField.resignFirstResponder()
        self.pwdField.resignFirstResponder()
        self.userNameField.isEnabled = false
        self.pwdField.isEnabled = false
        self.messageLabel.text = ""
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        self.activityIndicator.startAnimating()

        AuthorizationService.service.authenticate(userID: self.userNameField.text!, pwd: pwdField.text!) { (success: Bool, error: NSError?) in
            if success {
                self.doneHandler?()
            }
            else {
                self.loginBtn.isEnabled = true
                self.userNameField.isEnabled = true
                self.pwdField.isEnabled = true
                self.messageLabel.text = error?.localizedDescription
            }
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.activityIndicator.stopAnimating()
        }
    }
    
    @IBAction func textFieldEditingChanged(_ sender: Any) {
        if let n = self.userNameField.text, let p = self.pwdField.text {
            self.loginBtn.isEnabled = !n.isEmpty && !p.isEmpty
        }
        else {
            self.loginBtn.isEnabled = false
        }
    }
    
    @IBAction func returnKeyTapped(_ sender: UITextField) {
        if sender.canResignFirstResponder {
            sender.resignFirstResponder()
        }
        
        if sender == self.userNameField {
            self.pwdField.becomeFirstResponder()
        }
        else if sender == self.pwdField {
            self.loginBtnTapped(nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.loginBtn.isEnabled = false
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
