//
//  ServiceCenter.swift
//  ConchIOS
//
//  Created by osx on 2017/7/14.
//  Copyright © 2017年 osx. All rights reserved.
//

import UIKit

class ServiceCenter: NSObject {
    
    static let networkService = NetworkService(baseURL: URL(string: AppConfig.serverHost))
    static let authorizationService = AuthorizationService()
    static let examinationService = ExaminationService()
    
    static func start() {
        
    }
    
    static func cancel() {
        networkService.cancel()
        examinationService.cancel()
        authorizationService.authenticated = false
    }
}
