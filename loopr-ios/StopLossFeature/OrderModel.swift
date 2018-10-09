//
//  StopLossModel.swift
//  loopr-ios
//
//  Created by Anton Grigorev on 09.10.2018.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

class OrderCDModel {
    let price: String
    let hash: String
    
    init(order: OrderCD) {
        self.price = order.price ?? "0"
        self.hash = order.orderHash ?? ""
    }
    
    init(hash: String,
         price: String) {
        self.price = price
        self.hash = hash
    }
    
    static func fromCoreData(crModel: OrderCD) -> OrderCDModel {
        let model = OrderCDModel(hash: crModel.orderHash ?? "",
                                 price: crModel.price ?? "0" )
        return model
    }
}

extension OrderCDModel: Equatable {
    static func ==(lhs: OrderCDModel, rhs: OrderCDModel) -> Bool {
        return lhs.hash == rhs.hash
    }
}
