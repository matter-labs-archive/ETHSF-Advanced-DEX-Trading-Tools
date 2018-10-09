//
//  StopLossService.swift
//  loopr-ios
//
//  Created by Anton Grigorev on 09.10.2018.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

class OrdersService {
    func getCurrentOrdersFromServer(onPageWithIndex pageIndex: UInt,
                                    previousOrderCount: Int,
                                    completionHandler: @escaping (_ orders: [Order]?) -> Void) {
        OrderDataManager.shared.getOrdersFromServer(pageIndex: pageIndex, completionHandler: { (error) in
            DispatchQueue.main.async {
                if (error != nil) {
                    completionHandler(nil)
                }
                let orders = OrderDataManager.shared.getOrders(type: .open)
                completionHandler(orders)
            }
        })
    }
    
    func getCurrentOrdersFromCD() -> [OrderCDModel] {
        return OrdersDatabase().getAllOrders()
    }
    
    func findEqualOrderInCD(order: Order) -> OrderCDModel? {
        let orderCD = OrdersDatabase().getOrder(order: order)
        return orderCD
    }
}
