//
//  StopLossModel.swift
//  loopr-ios
//
//  Created by Anton Grigorev on 09.10.2018.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

class OrderCDModel {
    let stopLoss: String
    let hash: String
    
    init(order: OrderCD) {
        self.stopLoss = order.stopLoss ?? "0"
        self.hash = order.orderHash ?? ""
    }
    
    init(hash: String,
         stopLoss: String) {
        self.stopLoss = stopLoss
        self.hash = hash
    }
    
    init(hash: String) {
        self.stopLoss = "0"
        self.hash = hash
    }
    
    static func fromCoreData(crModel: OrderCD) -> OrderCDModel {
        let model = OrderCDModel(hash: crModel.orderHash ?? "",
                                 stopLoss: crModel.stopLoss ?? "0" )
        return model
    }
}

extension OrderCDModel: Equatable {
    static func ==(lhs: OrderCDModel, rhs: OrderCDModel) -> Bool {
        return lhs.hash == rhs.hash
    }
}
