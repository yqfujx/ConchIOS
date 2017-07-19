//
//  ViewController.swift
//  ConchIOS
//
//  Created by osx on 2017/7/12.
//  Copyright © 2017年 osx. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // MARK: - 成员
    private let service = ExaminationService.service
    private var selectedIndex: IndexPath?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var refreshBtn: UIButton!
    @IBOutlet weak var refreshBtnItem: UIBarButtonItem!
    @IBOutlet weak var bgView: UIView!
    
    // MARK: - 事件
    @IBAction func refreshBtnTaped(_ sender: Any?) {
        self.requestData()
    }
    
    // MARK: - 方法
    
    /**
     身份验证
     */
    func authenticate() -> Void {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        self.refreshBtn.isEnabled = false
        self.refreshBtnItem.isEnabled = false
        
        AuthorizationService.service.authenticate(completion: { (success: Bool, error: NSError?) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.refreshBtn.isEnabled = true
            self.refreshBtnItem.isEnabled = true
            
            if success {
                self.requestData()
            }
            else {
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "AuthenticateScene") as! AuthenticateViewController
                controller.modalTransitionStyle = .crossDissolve
                controller.doneBlock = { [unowned self] in
                    controller.dismiss(animated: true, completion: nil)
                    
                    self.requestData()
                }
                
                self.present(controller, animated: true, completion: nil)
            }
        })
    }
    
    /**
    请求新数据
     */
    func requestData() ->Void  {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        self.refreshBtn.isEnabled = false
        self.refreshBtnItem.isEnabled = false
        
        self.service.requestData { (success: Bool, error: SysError?) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.refreshBtn.isEnabled = true
            self.refreshBtnItem.isEnabled = true
            
            if success {
                self.tableView.reloadData()
            }
            else {
                // 提示错误信息
                debugPrint("\(String(describing: error?.localizedDescription))")
                if error!.code == ResponseCode.unauthorized.rawValue {
                    AuthorizationService.service.authenticate(completion: nil)
                }
            }
        }
    }
    
    // MARK: -  重载
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "待审清单"
        
        let auth = AuthorizationService.service
        // 未曾登录过要先登录
        if !auth.authenticated {
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "LoginScene") as! LoginViewController
            controller.doneHandler = { [unowned self] in
                controller.dismiss(animated: true, completion: nil)
                
                self.requestData()
            }
            self.present(controller, animated: false, completion: nil)
        }
        else {
            // 令牌过期了要重新申请令牌
            let expiredTime = auth.expiredTime
            if expiredTime! <= Date() {
                self.authenticate()
            }
            else {
                self.requestData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let indexPath = self.tableView.indexPathForSelectedRow {
            DispatchQueue.main.async {
                self.tableView.reloadRows(at: [indexPath], with: .fade)
            }
        }
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let num = self.service.repository.count
        tableView.isHidden = (num <= 0)
        return num
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ExaminationItemCell
        let item = self.service.repository.item(at: indexPath.row)
        var color = UIColor.darkText
        if item?.status != ExaminationItem.Status.pending {
            color = UIColor.lightGray
        }
        cell.textLabel0.textColor = color
        cell.textLabel1.textColor = color
        cell.textLabel2.textColor = color
        cell.textLabel3.textColor = color
        
        cell.textLabel0.text = item!.customer
        cell.textLabel1.text = String(format: "%d 袋", item!.damagedCount)
        cell.textLabel2.text = item!.damagedSpec
        cell.textLabel3.text = item!.submittingTime.string(with: "M-d H:m")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndex = indexPath
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ListToDetail" {
            let cell = sender as! UITableViewCell
            if let indexPath = self.tableView.indexPath(for: cell) {
                let item = self.service.repository.item(at: indexPath.row)
                let controller = segue.destination as! DetailViewController
                controller.item = item
            }
        }
    }
}

