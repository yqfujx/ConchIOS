//
//  AuthorizationService.swift
//  ConchIOS
//
//  Created by osx on 2017/7/12.
//  Copyright © 2017年 osx. All rights reserved.
//

import UIKit

class AuthorizationService: NSObject {
    // 变量
    
    // MARK: - 属性
    //
    var userID: String? {
        get {
            return AppConfig.userID
        }
        set {
            AppConfig.userID = newValue
        }
    }
    
    var password: String? {
        get {
            return AppConfig.password
        }
        set  {
            AppConfig.password = newValue
        }
    }
    let client = "iOS"
    let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    var deviceToken: String? {
        get {
            return AppConfig.deviceToken
        }
        set {
            AppConfig.deviceToken = newValue
        }
    }
    
    var sessionToken: String? {
        get {
            return AppConfig.sessionToken
        }
        set {
            AppConfig.sessionToken = newValue
        }
    }
    var expiredTime: Date? {
        get {
            return AppConfig.expiredTime
        }
        set {
            AppConfig.expiredTime = newValue
        }
    }
    
    var authenticated: Bool {
        get {
            return AppConfig.authenticated
        }
        set {
            AppConfig.authenticated = newValue
        }
    }
    
    // MARK: - 方法
    //
    func authenticate(userID: String, pwd: String, completion: ((Bool, NSError?) -> Void)?) -> Void {
        
        let request = Request.login(userID, pwd, client, self.appVersion, self.deviceToken)
        
        _ = ServiceCenter.networkService.send(request: request) { (success, dictionary, error) in
            if success {
                let result = dictionary![ResponseContentKey.result.rawValue] as! Int
                
                if result == ResponseCode.success.rawValue {
                    if let data = dictionary![ResponseContentKey.data.rawValue] as? [String: Any],
                        let token = data["token"] as? String,
                        let dateString = data["timeout"] as? String {
                        
                        self.userID = userID
                        self.password = pwd
                        self.sessionToken = token
                        self.expiredTime = Date(string: dateString, format: "yyyy-MM-dd HH:mm:ss")
                        self.authenticated = true
                        
                        completion?(true, nil)
                    }
                    else {
                        let error = SysError(domain: "Authorization", code: ErrorCode.badData.rawValue)
                        completion?(false, error)
                    }
                }
                else { // 业务失败
                    let error = SysError(domain: ErrorDomain.AuthorizationService.rawValue, code: result)
                    completion?(false, error)
                }
            } // if success
            else {
                completion?(false, error)
            }
        } // closure
    }
    
    func authenticate(completion: ((Bool, NSError?) -> Void)?) -> Void {
        self.authenticate(userID: self.userID!, pwd: self.password!, completion: completion)
    }
}
