//
//  ExaminationService.swift
//  ConchIOS
//
//  Created by osx on 2017/7/15.
//  Copyright © 2017年 osx. All rights reserved.
//

import UIKit

class ExaminationService: NSObject {
    private let operationQueue: OperationQueue!
    
    static let service = ExaminationService()
    let repository: IExaminationRepository! = ExaminationRepository()
    
    override init() {
        self.operationQueue = OperationQueue()
        self.operationQueue.name = "ExaminationServiceQueue"
    }

    func requestData(completion: ((Bool, SysError?) ->Void)?) -> Void {
        let request = Request.allExamination        
        
        _ = NetworkService.service.send(request: request, completionQueue: self.operationQueue, completion: { (success: Bool, dictionary: [String: Any]?, error: NSError?) in
            var boolArg = true
            var errorArg: SysError?
            
            if success {
                let result = dictionary![ResponseContentKey.result.rawValue] as! Int
                if result == ResponseCode.success.rawValue {
                    if let data = dictionary![ResponseContentKey.data.rawValue] as? [[String: Any]]{
                        if self.repository.append(from: data) < 0 {
                            boolArg = false
                            errorArg = SysError(domain: ErrorDomain.ExaminationService.rawValue, code: ErrorCode.badData.rawValue, userInfo: nil)
                        }
                    }
                    else {
                        boolArg = false
                        errorArg = SysError(domain: ErrorDomain.ExaminationService.rawValue, code: ErrorCode.badData.rawValue, userInfo: nil)
                    }
                }
                else { // 业务码不为成功
                    boolArg = false
                    errorArg = SysError(domain: ErrorDomain.ExaminationService.rawValue, code: result)
                }
            }
            else {
                boolArg = false
                errorArg = SysError(error: error!)
            }
            
            DispatchQueue.main.async {
                completion?(boolArg, errorArg)
            }
        })
    }
    
    func examine(item: ExaminationItem, status: ExaminationItem.Status, completion: ((Bool, ExaminationItem?, SysError?) ->Void)?) -> Void {
        let request = Request.examine(item.id, status.rawValue, AuthorizationService.service.userID!)
        
        _ = NetworkService.service.send(request: request, completion: { (success: Bool, dictionary: [String : Any]?, error: SysError?) in
            if success {
                let result = dictionary![ResponseContentKey.result.rawValue] as! Int
                if result != ResponseCode.success.rawValue {
                    let error = SysError(domain: ErrorDomain.ExaminationService.rawValue, code: result)
                    completion?(false, nil, error)
                }
                else if let data = dictionary!["data"] as? [String: Any], let id = data["id"] as? String,
                    let status = data["status"] as? Int,
                    let processor = data["processor"] as? String,
                    let timeString = data["processTime"] as? String, let processTime = Date(string: timeString, format: "yyyy-MM-dd'T'HH:mm:ss") {
                    
                    var item = self.repository.item(id: id)!
                    item.status = ExaminationItem.Status(rawValue: status)!
                    item.processor = processor
                    item.processTime = processTime
                    self.repository.update(item: item)
                    
                    completion?(true, item, nil)
                }
                else {
                    let error = SysError(domain: ErrorDomain.ExaminationService.rawValue, code: ErrorCode.badData.rawValue)
                    completion?(false, nil, error)
                }
            }
            else {
                completion?(false, nil, error)
            }
        })
    }
}
