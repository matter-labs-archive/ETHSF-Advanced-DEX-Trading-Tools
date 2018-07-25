//
//  SwitchTradeTokenTableViewCell.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/17/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class SwitchTradeTokenTableViewCell: UITableViewCell {

    var token: Token?

    // TODO: We may deprecate IBOutlet
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var iconView: IconView!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        theme_backgroundColor = GlobalPicker.backgroundColor
        baseView.theme_backgroundColor = GlobalPicker.cardBackgroundColor
        symbolLabel.setTitleDigitFont()
        balanceLabel.setSubTitleDigitFont()
    }

    func update() {
        if let token = token {
            let icon = UIImage(named: "Token-\(token.symbol)-\(Themes.getTheme())")
            if icon != nil {
                iconImageView.image = icon
                iconImageView.isHidden = false
                iconView.isHidden = true
            } else {
                iconView.isHidden = false
                iconView.symbol = token.symbol
                iconView.symbolLabel.text = token.symbol
                iconImageView.isHidden = true
            }
            let balance = CurrentAppWalletDataManager.shared.getBalance(of: token.symbol) ?? 0.0
            symbolLabel.text = "\(token.symbol) (\(token.source.capitalized))"
            balanceLabel.text = "\(balance) \(token.symbol)"
        }
    }

    class func getCellIdentifier() -> String {
        return "SwitchTradeTokenTableViewCell"
    }

    class func getHeight() -> CGFloat {
        return 90
    }

}
