//
//  NotificationName.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/17/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

extension Notification.Name {
    
    // Socket IO response notifications
    static let balanceResponseReceived = Notification.Name("balanceResponseReceived")
    static let priceQuoteResponseReceived = Notification.Name("priceQuoteResponseReceived")
    static let tickerResponseReceived = Notification.Name("tickerResponseReceived")
    static let trendResponseReceived = Notification.Name("trendResponseReceived")
    static let orderResponseReceived = Notification.Name("orderResponseReceived")
    
    // In-app notifications
    static let currentAppWalletSwitched = Notification.Name("currentAppWalletSwitched")
    static let needRelaunchCurrentAppWallet = Notification.Name("needRelaunchCurrentAppWallet")

    // Need to update UI
    static let languageChanged = NSNotification.Name(rawValue: "languageChanged")
}
