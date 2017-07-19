//
//  Network.swift
//  ConchIOS
//
//  Created by osx on 2017/7/12.
//  Copyright © 2017年 osx. All rights reserved.
//

import Foundation

enum HttpMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case PATCH = "PATCH"
    case DELETE = "DELETE"
    
}

enum Request {
    case hello
    case login(String, String, String?, String?, String?)
    case allExamination
    case examination(String)
    case examine(String, Int, String)
    
    var requiredAuth: Bool {
        get {
            switch self {
            case .hello, .login(_, _, _, _, _):
                return false
            default:
                return true
            }
        }
    }
    
    var isBarrier: Bool {
        get {
            switch self {
            case .login(_, _, _, _, _):
                return true
            default:
                return false
            }
        }
    }
    
    var api: (HttpMethod, String, [String: Any]?) {
        var method: HttpMethod!
        var path = ""
        var params: [String: Any] = [:]
        
        switch self {
        case .hello:
            method = .GET
            path = "api/Hello"
        case .login(let userID, let pwd, let client, let appVersion, let deviceToken):
            method = .POST
            path = "api/Account/Login"
            params = ["userID": userID, "password": pwd]
            if let client = client {
                params["client"] = client
            }
            if let appVersion = appVersion {
                params["appVersion"] = appVersion
            }
            if let deviceToken = deviceToken {
                params["deviceToken"] = deviceToken
            }
        case .allExamination:
            method = .GET
            path = "api/Examine"
        case .examination(let id):
            method = .GET
            path = "api/Examine"
            params = ["id": id]
        case .examine(let id, let status, let processor):
            method = .PUT
            path = "api/Examine"
            params = ["id": id, "processor": processor, "status": status]
        }
        
        path = path.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed)!
        return (method, path, params)
    }
}

enum ResponseCode : Int {
    case success = 200
    case unauthorized = 401
    case notFound = 404
    
    case databaseError = 1001
    case verifyCodeError = 1002
    case userNameUnexists = 2001
    case userNameOrPasswordError = 2002
}

enum  ResponseContentKey : String{
    case result = "result"
    case description = "desc"
    case data = "data"
}

enum ErrorCode: Int {
    case badData = 10001
}

enum ErrorDomain : String {
    case NetworkService = "NetworkService"
    case AuthorizationService = "AuthorizationService"
    case ExaminationService = "ExaminationService"
}

class SysError: NSError {
    override init(domain: String, code: Int, userInfo dict: [AnyHashable : Any]? = nil) {
        super.init(domain: domain, code: code, userInfo: dict)
    }
    
    convenience init(error: NSError) {
        self.init(domain: error.domain, code: error.code, userInfo: error.userInfo)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override var localizedDescription: String {
        get {
            var string = ""
            
            switch self.code {
                // 以下为HTTP协议错误代码
            case -1001 where self.domain == NSURLErrorDomain:
                string = "网络请求已超时"
                
                // 以下为业务处理结果错误代码
            case ResponseCode.success.rawValue:
                string = "成功"
            case ResponseCode.unauthorized.rawValue:
                string = "权限不足"
            case ResponseCode.notFound.rawValue:
                string = "访问的资源不存在"
            case ResponseCode.databaseError.rawValue:
                string = "数据库错误"
            case ResponseCode.verifyCodeError.rawValue:
                string = "验证码错误"
            case ResponseCode.userNameUnexists.rawValue:
                string = "用户名不存在"
            case ResponseCode.userNameOrPasswordError.rawValue:
                string = "用户名或密码错误"
                
                // 以下为通用错误代码
            case ErrorCode.badData.rawValue:
                string = "数据不完整，解析失败"
            default:
                string = super.localizedDescription
            }
            
            return string
        }
    }
}
