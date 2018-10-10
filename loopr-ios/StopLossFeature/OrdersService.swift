//
//  StopLossService.swift
//  loopr-ios
//
//  Created by Anton Grigorev on 09.10.2018.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

class OrdersService {
    public func getCurrentOrdersFromServer(onPageWithIndex pageIndex: UInt,
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
    
    public func getCurrentOrdersFromCD() -> [OrderCDModel] {
        return OrdersDatabase().getAllOrders()
    }
    
    public func findEqualOrderInCD(order: Order) -> OrderCDModel? {
        let orderCD = OrdersDatabase().getOrder(order: order)
        return orderCD
    }
    
    public func balanceForOrder(order: Order, orderCD: OrderCDModel, completion: @escaping (String?)->Void) {
        let market = MarketDataManager.shared.getMarket(byTradingPair: order.originalOrder.market)
        if market == nil {
            LoopringAPIRequest.getTicker(by: .coinmarketcap) { (markets, error) in
                guard error == nil else {
                    completion(nil)
                    return
                }
                MarketDataManager.shared.setMarkets(newMarkets: markets)
                let market = MarketDataManager.shared.getMarket(byTradingPair: order.originalOrder.market)
                let balance = market?.balance.withCommas(6)
                completion(balance)
            }
        }
        let balance = market?.balance.withCommas(6)
        completion(balance)
    }
}
