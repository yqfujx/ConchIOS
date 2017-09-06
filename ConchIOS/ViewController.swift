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
    private let service = ServiceCenter.examinationService
    private var selectedIndex: IndexPath?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var refreshBtn: UIButton!
    @IBOutlet weak var refreshBtnItem: UIBarButtonItem!
    @IBOutlet weak var bgView: UIView!
    
    // MARK: - 事件
    @IBAction func logOut(_ sender: Any?) {
        
        let alert = UIAlertController(title: nil, message: "确定要退出当前帐号吗？", preferredStyle: .alert)
        let positive = UIAlertAction(title: "确定", style: .default) { [weak self] (actiion: UIAlertAction) in
            ServiceCenter.cancel()
            
            guard let _self = self else {
                return
            }
            
            let controller = _self.storyboard?.instantiateViewController(withIdentifier: "LoginScene") as! LoginViewController
            controller.doneHandler = { [weak self] in
                controller.dismiss(animated: true, completion: nil)
                
                self?.requestData()
            }
            _self.present(controller, animated: false, completion: nil)
        }
        alert.addAction(positive)
        let negative = UIAlertAction(title: "取消", style: .cancel) { (action: UIAlertAction) in
        }
        alert.addAction(negative)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func refreshBtnTaped(_ sender: Any?) {
        self.requestData()
    }
    
    // MARK: - 方法
    
    /**
     系统重置消息
     */
    func onResetNotification(noti: Notification) -> Void {
        ServiceCenter.cancel()
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "LoginScene") as! LoginViewController
        controller.doneHandler = { [weak self] in
            controller.dismiss(animated: true, completion: nil)
            
            self?.requestData()
        }
        self.present(controller, animated: false, completion: nil)
    }
    
    /**
     身份验证
     */
    func authenticate() -> Void {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        self.refreshBtn.isEnabled = false
        self.refreshBtnItem.isEnabled = false
        
        ServiceCenter.authorizationService.authenticate(completion: { [weak self] (success: Bool, error: SysError?) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            guard let _self = self else {
                return
            }
            
            _self.refreshBtn.isEnabled = true
            _self.refreshBtnItem.isEnabled = true
            
            if success {
                _self.requestData()
            }
            else {
                switch error!.code {
                case ResponseCode.userNameOrPasswordError.rawValue, ResponseCode.userNameUnexists.rawValue:
                    NotificationCenter.default.post(name: NSNotification.Name(Noti_Reset), object: nil)
                default:
//                    let controller = self.storyboard?.instantiateViewController(withIdentifier: "AuthenticateScene") as! AuthenticateViewController
//                    controller.modalTransitionStyle = .crossDissolve
//                    controller.doneBlock = { [unowned self] in
//                        controller.dismiss(animated: true, completion: nil)
//                        
//                        self.requestData()
//                    }
//                    
//                    self.present(controller, animated: true, completion: nil)
                    break
                }
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
        
        self.service.requestData { [weak self] (success: Bool, error: SysError?) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            guard let _self = self else {
                return
            }
            
            _self.refreshBtn.isEnabled = true
            _self.refreshBtnItem.isEnabled = true
            
            if success {
                _self.tableView.reloadData()
            }
            else {
                // 提示错误信息
                debugPrint("\(String(describing: error?.localizedDescription))")
                if error!.code == ResponseCode.unauthorized.rawValue {
                    ServiceCenter.authorizationService.authenticate(completion: nil)
                }
            }
        } // end of closure
    }
    
    // MARK: -  重载
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "待审清单"
        NotificationCenter.default.addObserver(self, selector: #selector(onResetNotification(noti:)), name: NSNotification.Name(Noti_Reset), object: nil)
        
        let auth = ServiceCenter.authorizationService
        // 未曾登录过要先登录
        if !auth.authenticated {
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "LoginScene") as! LoginViewController
            controller.doneHandler = { [weak self] in
                controller.dismiss(animated: true, completion: nil)
                
                self?.requestData()
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
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.init(pushNotification), object: nil, queue: OperationQueue.main) { [weak self] (_: Notification) in
            self?.requestData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let indexPath = self.tableView.indexPathForSelectedRow {
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadRows(at: [indexPath], with: .fade)
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
        cell.textLabel3.text = item!.submittingTime.string(with: "MM-dd HH:mm")
        
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

