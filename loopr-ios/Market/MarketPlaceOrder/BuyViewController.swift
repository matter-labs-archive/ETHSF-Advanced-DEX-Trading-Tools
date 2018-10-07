//
//  BuyViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/10/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import Geth
import StepSlider

class BuyViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate, NumericKeyboardDelegate, NumericKeyboardProtocol, StepSliderDelegate {

    var market: Market!
    
    // container
    @IBOutlet weak var containerView: UIView!
    
    // TokenS
    @IBOutlet weak var tokenSButton: UIButton!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var priceTokenLabel: UILabel!
    @IBOutlet weak var estimateValueInCurrencyLabel: UILabel!
    @IBOutlet weak var sellTipLabel: UILabel!

    // TokenB
    @IBOutlet weak var tokenBButton: UIButton!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var amountTokenLabel: UILabel!
    @IBOutlet weak var buyTipLabel: UILabel!
    @IBOutlet weak var tipLabel: UILabel!
    
    // Slider
    @IBOutlet weak var sliderView: UIView!
    
    // TTL Buttons
    @IBOutlet weak var hourButton: UIButton!
    @IBOutlet weak var dayButton: UIButton!
    @IBOutlet weak var monthButton: UIButton!
    @IBOutlet weak var customButton: UIButton!
    
    // Place button
    @IBOutlet weak var nextButton: UIButton!
    
    // Scroll view
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewButtonLayoutConstraint: NSLayoutConstraint!
    
    var blurVisualEffectView = UIView(frame: .zero)
    
    // Drag down to close a present view controller.
    var dismissInteractor: MiniToLargeViewInteractive!

    // Numeric keyboard
    var isNumericKeyboardShow: Bool = false
    var numericKeyboardView: DefaultNumericKeyboard!
    var activeTextFieldTag = -1
    var stepSlider: StepSlider = StepSlider.getDefault()
    
    // Expires
    var buttons: [UIButton] = []
    var intervalValue = 1
    var intervalUnit: Calendar.Component = .hour
    
    // config
    var type: TradeType
    var initialPrice: String?
    var orderAmount: Double = 0
    var tokenS: String = ""
    var tokenB: String = ""
    
    convenience init(type: TradeType) {
        self.init(nibName: nil, bundle: nil)
        self.type = type
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        type = .buy
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setBackButton()
        view.theme_backgroundColor = ColorPicker.backgroundColor
        containerView.theme_backgroundColor = ColorPicker.cardBackgroundColor

        buyTipLabel.setTitleDigitFont()
        buyTipLabel.text = LocalizedString("Amount", comment: "")
        amountTokenLabel.setTitleDigitFont()
        amountTokenLabel.text = PlaceOrderDataManager.shared.tokenA.symbol
        tipLabel.setSubTitleCharFont()

        let textFieldLeftPadding = buyTipLabel.text!.textWidth(font: FontConfigManager.shared.getDigitalFont()) + 16

        // First row: TokenS
        priceTextField.delegate = self
        priceTextField.tag = 0
        priceTextField.inputView = UIView(frame: .zero)
        priceTextField.font = FontConfigManager.shared.getDigitalFont()
        priceTextField.theme_tintColor = GlobalPicker.contrastTextColor
        priceTextField.placeholder = LocalizedString("", comment: "")
        priceTextField.setLeftPaddingPoints(textFieldLeftPadding)
        priceTextField.setRightPaddingPoints(72)
        priceTextField.contentMode = UIViewContentMode.bottom
        
        sellTipLabel.setTitleDigitFont()
        sellTipLabel.text = LocalizedString("Price", comment: "")
        priceTokenLabel.setTitleDigitFont()
        priceTokenLabel.text = PlaceOrderDataManager.shared.tokenB.symbol
        estimateValueInCurrencyLabel.text = ""
        estimateValueInCurrencyLabel.setSubTitleCharFont()

        // Second row: TokenB
        amountTextField.delegate = self
        amountTextField.tag = 1
        amountTextField.inputView = UIView(frame: .zero)
        amountTextField.font = FontConfigManager.shared.getDigitalFont()
        amountTextField.theme_tintColor = GlobalPicker.contrastTextColor
        amountTextField.placeholder = LocalizedString("", comment: "")
        amountTextField.setLeftPaddingPoints(textFieldLeftPadding)
        amountTextField.setRightPaddingPoints(72)
        amountTextField.contentMode = UIViewContentMode.bottom
        
        // Slider
        let screenWidth = UIScreen.main.bounds.width
        stepSlider.frame = CGRect(x: 15, y: sliderView.frame.minY, width: screenWidth-15*4, height: 20)
        stepSlider.delegate = self
        stepSlider.maxCount = 4
        stepSlider.setIndex(0, animated: false)
        stepSlider.labels = ["0%", "25%", "50%", "75%", "100%"]
        containerView.addSubview(stepSlider)
        
        // Buttons
        hourButton.round(corners: [.topLeft, .bottomLeft], radius: 8)
        customButton.round(corners: [.topRight, .bottomRight], radius: 8)
        hourButton.title = LocalizedString("1 Hour", comment: "")
        dayButton.title = LocalizedString("1 Day", comment: "")
        monthButton.title = LocalizedString("1 Month", comment: "")
        customButton.title = LocalizedString("Custom", comment: "")
        buttons = [hourButton, dayButton, monthButton, customButton]
        hourButton.titleLabel?.font = FontConfigManager.shared.getBoldFont()
        buttons.forEach {
            $0.titleLabel?.font = FontConfigManager.shared.getRegularFont(size: 13)
            $0.theme_backgroundColor = ColorPicker.cardHighLightColor
            $0.theme_setTitleColor(GlobalPicker.textColor, forState: .selected)
            $0.theme_setTitleColor(GlobalPicker.textLightColor, forState: .normal)
        }
        
        // Place button
        if type == .buy {
            nextButton.title = LocalizedString("Buy", comment: "") + " " + market.tradingPair.tradingA
            nextButton.setupPrimary(height: 44, gradientOrientation: .horizontal)
        } else {
            nextButton.title = LocalizedString("Sell", comment: "") + " " + market.tradingPair.tradingA
            nextButton.setupRed(height: 44, gradientOrientation: .horizontal)
        }
        
        // Scroll view
        let scrollViewTap = UITapGestureRecognizer(target: self, action: #selector(scrollViewTapped))
        scrollViewTap.numberOfTapsRequired = 1
        scrollView.addGestureRecognizer(scrollViewTap)
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: containerView.frame.maxY)
        
        // TODO: This cause wired animation.
        scrollView.delaysContentTouches = false

        self.scrollViewButtonLayoutConstraint.constant = 0
        
        blurVisualEffectView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        blurVisualEffectView.alpha = 1
        blurVisualEffectView.frame = UIScreen.main.bounds
        
        containerView.applyShadow()
        
        if let initialPrice = initialPrice {
            priceTextField.text = initialPrice.trailingZero()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        update()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        customButton.round(corners: [.topRight, .bottomRight], radius: 8)
    }
    
    func update() {
        var message: String = ""
        let title = LocalizedString("Available Balance", comment: "")
        if self.type == .buy {
            self.tokenB = PlaceOrderDataManager.shared.tokenA.symbol
            self.tokenS = PlaceOrderDataManager.shared.tokenB.symbol
        } else {
            self.tokenB = PlaceOrderDataManager.shared.tokenB.symbol
            self.tokenS = PlaceOrderDataManager.shared.tokenA.symbol
        }
        if let asset = CurrentAppWalletDataManager.shared.getAsset(symbol: tokenS) {
            message = "\(title) \(asset.display) \(self.tokenS)"
        } else {
            message = "\(title) 0.0 \(tokenS)"
        }
        tipLabel.text = message
        
        getRangePrices { [weak self] (result) in
            self?.setRangePrices(for: result)
        }
    }
    
    func setRangePrices(for prices: (minSell: Double?, maxBuy: Double?)) {
        let (minSell, maxBuy) = prices
        let price = type == .buy ? minSell : maxBuy
        priceTextField.text = price != nil ? String(format:"%f", price!) : nil
        if price == nil {
            let depthType = type == .buy ? "sell" : "buy"
            estimateValueInCurrencyLabel.isHidden = false
            estimateValueInCurrencyLabel.textColor = .fail
            estimateValueInCurrencyLabel.text = "No \(depthType) depths in market"
            estimateValueInCurrencyLabel.shake()
        }
    }
    
    @objc func scrollViewTapped() {
        print("scrollViewTapped")
        priceTextField.resignFirstResponder()
        amountTextField.resignFirstResponder()
        hideNumericKeyboard()
    }
    
    @IBAction func pressedUpdatePriceButton(_ sender: Any) {
        print("pressedUpdatePriceButton")
        presentMarketDetailDepthModalViewController()
    }

    @IBAction func pressedUpdateAmountButton(_ sender: Any) {
        print("pressedUpdateAmountButton")
        presentMarketDetailDepthModalViewController()
    }
    
    func presentMarketDetailDepthModalViewController() {
        let nextViewController = MarketDetailDepthModalViewController()
        nextViewController.market = market
        nextViewController.delegate = self
        // nextViewController.transitioningDelegate = self
        nextViewController.modalPresentationStyle = .overFullScreen
        
        dismissInteractor = MiniToLargeViewInteractive()
        // dismissInteractor.attachToViewController(viewController: nextViewController, withView: nextViewController.view, presentViewController: nil, backgroundView: blurVisualEffectView)
        
        self.present(nextViewController, animated: true) {
            
        }
        
        self.navigationController?.view.addSubview(self.blurVisualEffectView)
        UIView.animate(withDuration: 0.3, animations: {
            self.blurVisualEffectView.alpha = 1.0
        }, completion: {(_) in
            
        })
    }

    @IBAction func pressedExpiresButton(_ sender: UIButton) {
        let dict: [Int: Calendar.Component] = [0: .hour, 1: .day, 2: .month]
        for (index, button) in buttons.enumerated() {
            button.titleLabel?.font = FontConfigManager.shared.getRegularFont(size: 13)
            button.theme_setTitleColor(GlobalPicker.textLightColor, forState: .normal)
            if button == sender {
                if index < 3 {
                    self.intervalValue = 1
                    self.intervalUnit = dict[index]!
                } else if index == 3 {
                    self.present()
                }
            }
            button.isSelected = false
        }
        sender.isSelected = true
        sender.titleLabel?.font = FontConfigManager.shared.getBoldFont()
    }
    
    func present() {
        self.hideNumericKeyboard()
        let parentView = self.parent!.view!
        parentView.alpha = 0.25
        let vc = TimeToLiveViewController()
        vc.dismissClosure = {
            parentView.alpha = 1
            self.intervalUnit = vc.intervalUnit
            self.intervalValue = vc.intervalValue
        }
        vc.parentNavController = self.navigationController
        vc.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        self.present(vc, animated: true, completion: nil)
    }
    
    func stepSliderValueChanged(_ value: Double) {
        var message: String = ""
        let length = Asset.getLength(of: tokenS) ?? 4
        let title = LocalizedString("Available Balance", comment: "")
        if let asset = CurrentAppWalletDataManager.shared.getAsset(symbol: tokenS) {
            message = "\(title) \(asset.display) \(tokenS)"
            amountTextField.text = (asset.balance * value).withCommas(length)
//            // Only validate when balance is larger than 0.
//            if asset.balance > 0 {
//                _ = validate()
//            }
        } else {
            message = "\(title) 0.0 \(tokenS)"
            amountTextField.text = "0.0"
        }
        tipLabel.text = message
        tipLabel.textColor = .text1
        activeTextFieldTag = amountTextField.tag
    }

    // To avoid gesture conflicts in swiping to back and UISlider
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view != nil && touch.view!.isKind(of: StepSlider.self) {
            return false
        }
        return true
    }

    func getBalance() -> Double? {
        if let asset = CurrentAppWalletDataManager.shared.getAsset(symbol: tokenS) {
            return asset.balance
        }
        return nil
    }
    
    func constructOrder() -> OriginalOrder? {
        var buyNoMoreThanAmountB: Bool
        var side, tokenSell, tokenBuy: String
        var amountBuy, amountSell, lrcFee: Double
        if self.type == .buy {
            side = "buy"
            tokenBuy = PlaceOrderDataManager.shared.tokenA.symbol
            tokenSell = PlaceOrderDataManager.shared.tokenB.symbol
            buyNoMoreThanAmountB = true
            amountBuy = Double(amountTextField.text!)!
            amountSell = self.orderAmount
        } else {
            side = "sell"
            tokenBuy = PlaceOrderDataManager.shared.tokenB.symbol
            tokenSell = PlaceOrderDataManager.shared.tokenA.symbol
            buyNoMoreThanAmountB = false
            amountBuy = self.orderAmount
            amountSell = Double(amountTextField.text!)!
        }

        lrcFee = getLrcFee(amountSell, tokenSell)
        let delegate = RelayAPIConfiguration.delegateAddress
        let address = CurrentAppWalletDataManager.shared.getCurrentAppWallet()!.address
        let since = Int64(Date().timeIntervalSince1970)
        let until = Int64(Calendar.current.date(byAdding: intervalUnit, value: intervalValue, to: Date())!.timeIntervalSince1970)
        var order = OriginalOrder(delegate: delegate, address: address, side: side, tokenS: tokenSell, tokenB: tokenBuy, validSince: since, validUntil: until, amountBuy: amountBuy, amountSell: amountSell, lrcFee: lrcFee, buyNoMoreThanAmountB: buyNoMoreThanAmountB)
        PlaceOrderDataManager.shared.completeOrder(&order)
        return order
    }

    @IBAction func pressedPlaceOrderButton(_ sender: Any) {
        print("pressedPlaceOrderButton")
        hideNumericKeyboard()
        priceTextField.resignFirstResponder()
        amountTextField.resignFirstResponder()
        
        let isPriceValid = validateTokenPrice()
        let isAmountValid = validateAmount()
        if isPriceValid && isAmountValid {
            self.pushController()
        }
        if !isPriceValid {
            estimateValueInCurrencyLabel.textColor = .fail
            estimateValueInCurrencyLabel.isHidden = false
            estimateValueInCurrencyLabel.text = LocalizedString("Please input a valid price", comment: "")
            estimateValueInCurrencyLabel.shake()
        }
        if !isAmountValid {
            tipLabel.textColor = .fail
            tipLabel.isHidden = false
            tipLabel.text = LocalizedString("Please input a valid amount", comment: "")
            tipLabel.shake()
        }
    }

    func pushController() {
        if let order = constructOrder() {
            let viewController = PlaceOrderConfirmationViewController()
            viewController.order = order
            viewController.price = priceTextField.text
            
            // viewController.transitioningDelegate = self
            viewController.modalPresentationStyle = .overFullScreen
            viewController.dismissClosure = {
                UIView.animate(withDuration: 0.2, animations: {
                    self.blurVisualEffectView.alpha = 0.0
                }, completion: {(_) in
                    self.blurVisualEffectView.removeFromSuperview()
                })
            }
            
            dismissInteractor = MiniToLargeViewInteractive()
            dismissInteractor.percentThreshold = 0.2
            dismissInteractor.dismissClosure = {
                
            }
            
            self.present(viewController, animated: true) {
                // self.dismissInteractor.attachToViewController(viewController: viewController, withView: viewController.containerView, presentViewController: nil, backgroundView: self.blurVisualEffectView)
            }
            
            self.navigationController?.view.addSubview(self.blurVisualEffectView)
            UIView.animate(withDuration: 0.3, animations: {
                self.blurVisualEffectView.alpha = 1.0
            }, completion: {(_) in
                
            })
            
            viewController.parentNavController = self.navigationController
        }
    }
    
    func validateTokenPrice() -> Bool {
        if let value = Double(priceTextField.text ?? "0") {
            let validate = value > 0.0
            if validate {
                let tokenBPrice = PriceDataManager.shared.getPrice(of: PlaceOrderDataManager.shared.tokenB.symbol)!
                let estimateValue: Double = value * tokenBPrice
                estimateValueInCurrencyLabel.text = "≈ \(estimateValue.currency)"
                estimateValueInCurrencyLabel.isHidden = false
                estimateValueInCurrencyLabel.textColor = .text1
            } else {
                estimateValueInCurrencyLabel.text = LocalizedString("Please input a valid price", comment: "")
                estimateValueInCurrencyLabel.isHidden = false
                estimateValueInCurrencyLabel.textColor = .fail
                estimateValueInCurrencyLabel.shake()
            }
            return validate
        } else {
            if activeTextFieldTag == priceTextField.tag {
                estimateValueInCurrencyLabel.isHidden = true
            }
            return false
        }
    }
   
    func setupLabels() {
        if let balance = getBalance() {
            let title = LocalizedString("Available Balance", comment: "")
            tipLabel.isHidden = false
            tipLabel.textColor = .text1
            tipLabel.text = "\(title) \(balance.withCommas()) \(self.tokenS)"
        }
    }
    
    func validateAmount() -> Bool {
        if let value = Double(amountTextField.text ?? "0") {
            let validate = value > 0.0
            if validate {
                if type == .buy {
                    tipLabel.isHidden = true
                } else {
                    setupLabels()
                }
            } else {
                tipLabel.isHidden = false
                tipLabel.textColor = .fail
                tipLabel.text = LocalizedString("Please input a valid amount", comment: "")
                tipLabel.shake()
            }
            return validate
        } else {
            if activeTextFieldTag == amountTextField.tag {
                if type == .buy {
                    tipLabel.isHidden = true
                } else {
                    setupLabels()
                }
            }
            return false
        }
    }

    func validate() -> Bool {
        var isValid = false
        if activeTextFieldTag == priceTextField.tag {
            isValid = validateTokenPrice()
        } else if activeTextFieldTag == amountTextField.tag {
            isValid = validateAmount()
        } else {
            isValid = validateTokenPrice() && validateAmount()
        }
        guard isValid else {
            return false
        }
        if validateTokenPrice() && validateAmount() {
            isValid = true
            var total: Double
            total = Double(priceTextField.text!)! * Double(amountTextField.text!)!
            self.orderAmount = total
            setupLabels()
        }
        return isValid
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        print("textFieldShouldBeginEditing")
        activeTextFieldTag = textField.tag
        showNumericKeyboard(textField: textField)
        _ = validate()
        return true
    }
    
    func getActiveTextField() -> UITextField? {
        if activeTextFieldTag == priceTextField.tag {
            return priceTextField
        } else if activeTextFieldTag == amountTextField.tag {
            return amountTextField
        } else {
            return nil
        }
    }
    
    func showNumericKeyboard(textField: UITextField) {
        if !isNumericKeyboardShow {
            let width = self.view.frame.width
            let height = self.view.frame.height

            scrollViewButtonLayoutConstraint.constant = DefaultNumericKeyboard.height
            
            numericKeyboardView = DefaultNumericKeyboard(frame: CGRect(x: 0, y: height, width: width, height: DefaultNumericKeyboard.height))
            numericKeyboardView.delegate = self
            view.addSubview(numericKeyboardView)
            
            let destinateY = height - DefaultNumericKeyboard.height
            
            // TODO: improve the animation.
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                self.numericKeyboardView.frame = CGRect(x: 0, y: destinateY, width: width, height: DefaultNumericKeyboard.height)
            }, completion: { finished in
                self.isNumericKeyboardShow = true
                if finished {
                    if textField.tag == self.amountTextField.tag {
                        let bottomOffset = CGPoint(x: 0, y: self.scrollView.contentSize.height - self.scrollView.bounds.size.height)
                        self.scrollView.setContentOffset(bottomOffset, animated: true)
                    }
                }
            })
        } else {
            if textField.tag == amountTextField.tag {
                let bottomOffset = CGPoint(x: 0, y: self.scrollView.contentSize.height - self.scrollView.bounds.size.height)
                self.scrollView.setContentOffset(bottomOffset, animated: true)
            }
        }
    }
    
    func hideNumericKeyboard() {
        if isNumericKeyboardShow {
            let width = self.view.frame.width
            let height = self.view.frame.height
            let destinateY = height
            self.scrollViewButtonLayoutConstraint.constant = 0
            // TODO: improve the animation.
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                // animation for layout constraint change.
                self.view.layoutIfNeeded()
                self.numericKeyboardView.frame = CGRect(x: 0, y: destinateY, width: width, height: DefaultNumericKeyboard.height)
            }, completion: { finished in
                self.isNumericKeyboardShow = false
                if finished {
                }
            })
        } else {
            self.scrollView.setContentOffset(CGPoint.zero, animated: true)
        }
    }
    
    func numericKeyboard(_ numericKeyboard: NumericKeyboard, itemTapped item: NumericKeyboardItem, atPosition position: Position) {
        print("pressed keyboard: (\(position.row), \(position.column))")
        let activeTextField = getActiveTextField()
        guard activeTextField != nil else {
            return
        }
        var currentText = activeTextField!.text ?? ""
        switch (position.row, position.column) {
        case (3, 0):
            if !currentText.contains(".") {
                activeTextField!.text = currentText + "."
            }
        case (3, 1):
            activeTextField!.text = currentText + "0"
        case (3, 2):
            if currentText.count > 0 {
                currentText = String(currentText.dropLast())
            }
            activeTextField!.text = currentText
        default:
            let itemValue = position.row * 3 + position.column + 1
            activeTextField!.text = currentText + String(itemValue)
        }
        _ = validate()
    }

    func numericKeyboard(_ numericKeyboard: NumericKeyboard, itemLongPressed item: NumericKeyboardItem, atPosition position: Position) {
        print("Long pressed keyboard: (\(position.row), \(position.column))")
        
        let activeTextField = getActiveTextField()
        guard activeTextField != nil else {
            return
        }
        var currentText = activeTextField!.text ?? ""
        if (position.row, position.column) == (3, 2) {
            if currentText.count > 0 {
                currentText = String(currentText.dropLast())
            }
            activeTextField!.text = currentText
        }
    }
    
    @IBAction func setBestPrice(_ sender: UIButton) {
        getRangePrices { [weak self] (result) in
            self?.setRangePrices(for: result)
        }
    }
    
    func getRangePrices(completion: @escaping((minSell: Double?, maxBuy: Double?)) -> Void) {
        let buys = MarketDepthDataManager.shared.getBuys()
        let sells = MarketDepthDataManager.shared.getSells()
        print("buys")
        var buyPrices = [Double]()
        for buy in buys {
            print(buy.price)
            if let priceInDouble = Double(buy.price) {
                buyPrices.append(priceInDouble)
            }
            
        }
        let buyMax = buyPrices.max()
        print("sells")
        var sellPrices = [Double]()
        for sell in sells {
            print(sell.price)
            if let priceInDouble = Double(sell.price) {
                sellPrices.append(priceInDouble)
            }
        }
        let sellMin = sellPrices.min()
        
        completion((minSell: sellMin,
                    maxBuy: buyMax))
        
    }
}

extension BuyViewController: UIViewControllerTransitioningDelegate {

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = MiniToLargeViewAnimator()
        animator.initialY = 0
        animator.transitionType = .Dismiss
        return animator
    }

    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        // guard !disableInteractivePlayerTransitioning else { return nil }
        return dismissInteractor
    }

}

extension BuyViewController: MarketDetailDepthModalViewControllerDelegate {
    
    func dismissedMarketDetailDepthModalViewController() {
        UIView.animate(withDuration: 0.1, animations: {
            self.blurVisualEffectView.alpha = 0.0
        }, completion: {(_) in
            self.blurVisualEffectView.removeFromSuperview()
        })
    }

    func dismissWithSelectedDepth(amount: String, price: String) {
        priceTextField.text = price.trailingZero()
        let token = PlaceOrderDataManager.shared.tokenB.symbol
        let tokenBPrice = PriceDataManager.shared.getPrice(of: token)!
        let estimateValue: Double = (Double(priceTextField.text!) ?? 0) * tokenBPrice
        estimateValueInCurrencyLabel.isHidden = false
        estimateValueInCurrencyLabel.text = "≈ \(estimateValue.currency)"
        UIView.animate(withDuration: 0.1, animations: {
            self.blurVisualEffectView.alpha = 0.0
        }, completion: {(_) in
            self.blurVisualEffectView.removeFromSuperview()
        })
    }
}

extension BuyViewController {
    
    func getLrcFee(_ amountS: Double, _ tokenS: String) -> Double {
        var result: Double = 0
        let pair = tokenS + "/LRC"
        let ratio = SettingDataManager.shared.getLrcFeeRatio()
        if let market = MarketDataManager.shared.getMarket(byTradingPair: pair) {
            result = market.balance * amountS * ratio
        } else if let price = PriceDataManager.shared.getPrice(of: tokenS),
            let lrcPrice = PriceDataManager.shared.getPrice(of: "LRC") {
            result = price * amountS * ratio / lrcPrice
        }
        // do not know what this logic for. temp annotation
        let minLrc = GasDataManager.shared.getGasAmount(by: "eth_transfer", in: "LRC")
        return max(result, minLrc)
    }
}
