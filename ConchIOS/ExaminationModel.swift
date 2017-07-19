//
//  ExaminationModel.swift
//  ConchIOS
//
//  Created by osx on 2017/7/15.
//  Copyright © 2017年 osx. All rights reserved.
//

import UIKit

struct ExaminationItem {
    enum  Status : Int{
        case pending = 0
        case approved = 1
        case rejected = 2
    }
    
    let id: String
    let serialNo: String
    let billOfLading: String
    let customer: String
    let damagedCount: Int
    let damagedSpec: String
    let vehicleId: String
    let submitter: String
    let submittingTime: Date
    var status: Status = .pending
    var processor: String?
    var processTime: Date?
    
    init(id: String, serialNo: String, billOfLading: String, customer: String, damagedCount: Int, damagedSpec: String, vehicleId: String, submitter: String, submittingTime: Date) {
        self.id = id
        self.serialNo = serialNo
        self.billOfLading = billOfLading
        self.customer = customer
        self.damagedCount = damagedCount
        self.damagedSpec = damagedSpec
        self.vehicleId = vehicleId
        self.submitter = submitter
        self.submittingTime = submittingTime
    }
}

protocol IExaminationRepository {
    var count: Int { get }
    var all: [ExaminationItem] { get }
    func item(id: String) -> ExaminationItem?
    func item(at index: Int) ->ExaminationItem?
    func append(from keyValuePairsArray: [[String: Any]]) ->Int
    func append(from keyValuePair: [String: Any]) ->Bool
    func update(item: ExaminationItem) ->Void
    func removeAll() ->Void
}

class ExaminationRepository: IExaminationRepository {
    private var _repo = [ExaminationItem]()
    
    var count: Int {
        get {
            return _repo.count
        }
    }

    var all: [ExaminationItem] {
        get {
            return _repo
        }
    }
    
    func item(id: String) -> ExaminationItem? {
        if let index = _repo.index(where: { elem  in elem.id == id }) {
            return _repo[index]
        }
        return nil
    }

    func item(at index: Int) -> ExaminationItem? {
        if index >= 0 && index < _repo.count {
            return _repo[index]
        }
        else {
            return nil
        }
    }
    
    func append(from keyValuePair: [String : Any]) -> Bool {
        if let id = keyValuePair["id"] as? String,
            let serialNo = keyValuePair["serialNo"] as? String,
            let billOfLading = keyValuePair["billOfLading"] as? String,
            let customer = keyValuePair["customer"] as? String,
            let damagedCount = keyValuePair["damagedCount"] as? Int,
            let damagedSpec = keyValuePair["damagedSpec"] as? String,
            let vehicleId = keyValuePair["vehicleId"] as? String,
            let submitter = keyValuePair["submitter"] as? String,
            let timeString = keyValuePair["submittingTime"] as? String {
            
            let submittingTime = Date(string: timeString, format: "yyyy-MM-dd'T'HH:mm:ss")
            
            let item = ExaminationItem(id: id, serialNo: serialNo, billOfLading: billOfLading, customer: customer, damagedCount: damagedCount, damagedSpec: damagedSpec, vehicleId: vehicleId, submitter: submitter, submittingTime: submittingTime!)
            _repo.append(item)
            return true
        }
        return false
    }
    
    func append(from keyValuePairsArray: [[String : Any]]) -> Int {
        var count = 0
        
        for pair in keyValuePairsArray {
            if self.append(from: pair){
                count += 1
            }
            else {
                return -1
            }
        }
        
        return count
    }
    
    func update(item: ExaminationItem) {
        if let index = _repo.index(where: { elem  in elem.id == item.id }) {
            _repo[index] = item
        }
    }
    
    func removeAll() -> Void {
        _repo = []
    }
}


