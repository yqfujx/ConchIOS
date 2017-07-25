//
//  DetailViewController.swift
//  ConchIOS
//
//  Created by osx on 2017/7/16.
//  Copyright © 2017年 osx. All rights reserved.
//

import UIKit

class DetailViewController: UITableViewController {
    var item: ExaminationItem!
    
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var serialNoLabel: UILabel!
    @IBOutlet weak var billOfLadingLabel: UILabel!
    @IBOutlet weak var customer: UILabel!
    @IBOutlet weak var damagdCountLabel: UILabel!
    @IBOutlet weak var damagedSpecLabel: UILabel!
    @IBOutlet weak var vechicleIdLabel: UILabel!
    @IBOutlet weak var submitterLabel: UILabel!
    @IBOutlet weak var submittingTimeLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var approveBtn: UIButton!
    @IBOutlet weak var rejectBtn: UIButton!
    @IBOutlet weak var processorLabel: UILabel!
    @IBOutlet weak var processTimeLabel: UILabel!
    
    @IBAction func approveBtnTaped(_ sender: Any?) {
        self.examine(status: .approved)
    }
    
    @IBAction func rejectBtnTaped(_ sender: Any?) {
        self.examine(status: .rejected)
    }
    
    func examine(status: ExaminationItem.Status) -> Void {
        self.approveBtn.isEnabled = false
        self.rejectBtn.isEnabled = false
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let service = ServiceCenter.examinationService
        
        _ = service.examine(item: self.item, status: status, completion: { [weak self] (success: Bool, newItem: ExaminationItem?, error: SysError?) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            if success {
                self?.item = newItem!
                self?.show(item: (self?.item)!)
            }
            else {
                self?.approveBtn.isEnabled = true
                self?.rejectBtn.isEnabled = true
                if error!.code == ResponseCode.unauthorized.rawValue {
                    ServiceCenter.authorizationService.authenticate(completion: nil)
                }
            }
        })
    }
    
    func show(item: ExaminationItem) {
        self.idLabel.text = item.id
        self.serialNoLabel.text = item.serialNo
        self.billOfLadingLabel.text = item.billOfLading
        self.customer.text = item.customer
        self.damagdCountLabel.text = String(format: "%d 袋", item.damagedCount)
        self.damagedSpecLabel.text = item.damagedSpec
        self.vechicleIdLabel.text = item.vehicleId
        self.submitterLabel.text = item.submitter
        self.submittingTimeLabel.text = item.submittingTime.string(with: "yyyy-MM-dd HH:mm:ss")
        switch item.status {
        case .pending:
            self.statusLabel.text = "待处理"
        case .approved:
            self.statusLabel.text = "已批准补包"
        case .rejected:
            self.statusLabel.text = "不予补包"
        }
        self.processorLabel.text = item.processor ?? "--"
        self.processTimeLabel.text = item.processTime?.string(with: "yyyy-MM-dd HH:mm:ss") ?? "--"
        
        if item.status != .pending {
            self.approveBtn.isEnabled = false
            self.rejectBtn.isEnabled = false
        }
        
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "明细"
        
        self.approveBtn.setBackground(color: UIColor(red: 75.0 / 255.0, green: 186.0 / 255.0, blue: 81.0 / 255.0, alpha: 1.0), forState: .normal)
        self.approveBtn.setBackground(color: UIColor(white: 0.9, alpha: 1.0), forState: .disabled)
        self.approveBtn.setTitleColor(UIColor.white, for: .normal)
        self.approveBtn.setTitleColor(UIColor.gray, for: .disabled)
        self.rejectBtn.setBackground(color: UIColor(red: 212.0 / 255.0, green: 52.0 / 255.0, blue: 52.0 / 255.0, alpha: 1.0), forState: .normal)
        self.rejectBtn.setBackground(color: UIColor(white: 0.9, alpha: 1.0), forState: .disabled)
        self.rejectBtn.setTitleColor(UIColor.white, for: .normal)
        self.rejectBtn.setTitleColor(UIColor.gray, for: .disabled)
        
        // setup properties
        self.show(item: self.item)
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
