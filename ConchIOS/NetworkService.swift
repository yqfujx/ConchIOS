//
//  NetworkService.swift
//  ConchIOS
//
//  Created by osx on 2017/7/12.
//  Copyright © 2017年 osx. All rights reserved.
//

import UIKit
import AFNetworking

class NetworkService: AFHTTPSessionManager {
    // MARK: - 成员
    private var sendDispatchQueue: DispatchQueue!
    
    // MARK: - 属性
    static let service = NetworkService(baseURL: URL(string: AppConfig.serverHost))
    
    override init(baseURL url: URL?, sessionConfiguration configuration: URLSessionConfiguration? = URLSessionConfiguration.default) {
        super.init(baseURL: url, sessionConfiguration: configuration)
        self.requestSerializer = AFJSONRequestSerializer()
        self.responseSerializer = AFJSONResponseSerializer()
        
        self.sendDispatchQueue = DispatchQueue(label: "NetworkService send dispatch queue", qos: .userInitiated, attributes: .concurrent)
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     发送HTTP请求
     */
   
    func send(request: Request, completionQueue: OperationQueue?, completion: ((Bool, [String: Any]?, SysError?) ->Void)?) -> Bool {
        if request.requiredAuth, let token = AuthorizationService.service.sessionToken {
            self.requestSerializer.setValue("\(token)", forHTTPHeaderField: "token")
        }
        else {
            self.requestSerializer.setValue(nil, forHTTPHeaderField: "token")
        }
        
        let success = {(task: URLSessionDataTask, data: Any?) in
            if let dictionary = data as? [String : Any],  let _ = dictionary[ResponseContentKey.result.rawValue] as? Int {
                completionQueue?.addOperation {
                    completion?(true, dictionary, nil)
                }
            }
            else {
                let error = SysError(domain: ErrorDomain.NetworkService.rawValue, code: ErrorCode.badData.rawValue)
                completionQueue?.addOperation {
                    completion?(false, nil, error)
                }
            }
        }
        
        let failure = { (task: URLSessionDataTask?, error: Error) in
            let error = error as NSError
            var sysError: SysError
            
            if let res = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey] as? HTTPURLResponse {
                let code = res.statusCode
                sysError = SysError(domain: ErrorDomain.NetworkService.rawValue, code: code)
            }
            else {
                sysError = SysError(error: error)
            }
            
            completionQueue?.addOperation {
                completion?(false, nil, sysError)
            }
        }
        
        let (method, path, params) = request.api
        let url = URL(string: path, relativeTo: self.baseURL)?.absoluteString
        let flag: DispatchWorkItemFlags = request.isBarrier ? .barrier : .inheritQoS // 身份验证需要以独占方式调用
        
        let work = DispatchWorkItem(qos: .userInitiated, flags: flag) {
            switch method {
            case .GET:
                _ = self.get(url!, parameters: params, progress: nil, success: success, failure: failure)
            case .POST:
                _ = self.post(url!, parameters: params, progress: nil, success: success, failure: failure)
            case .PUT:
                _ = self.put(url!, parameters: params, success: success, failure: failure)
            case .PATCH:
                _ = self.patch(url!, parameters: params, success: success, failure: failure)
            case .DELETE:
                _ = self.delete(url!, parameters: params, success: success, failure: failure)
            }
        }
        self.sendDispatchQueue.async(execute: work)
        
        return true
    }
    
    func send(request: Request, completion: ((Bool, [String: Any]?, SysError?) ->Void)?) -> Bool {
        return send(request: request, completionQueue: OperationQueue.main, completion: completion)
    }
}
