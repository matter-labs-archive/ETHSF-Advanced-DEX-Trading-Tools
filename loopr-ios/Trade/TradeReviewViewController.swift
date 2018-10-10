//
//  TradeConfirmationViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/13/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class TradeReviewViewController: UIViewController {
    
    @IBOutlet weak var tokenS: UIView!
    @IBOutlet weak var tokenB: UIView!
    @IBOutlet weak var arrowRightImageView: UIImageView!
    @IBOutlet weak var qrcodeImageView: UIImageView!
    @IBOutlet weak var statusTipLabel: UILabel!
    @IBOutlet weak var statusInfoLabel: UILabel!
    @IBOutlet weak var validTipLabel: UILabel!
    @IBOutlet weak var validInfoLabel: UILabel!
    
    @IBOutlet weak var shareContentView: UIView!
    @IBOutlet weak var shareImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleImageInShare: UIImageView!
    @IBOutlet weak var qrcodeInShare: UIImageView!
    @IBOutlet weak var sellTipLabel: UILabel!
    @IBOutlet weak var sellInfoLabel: UILabel!
    @IBOutlet weak var buyTipLabel: UILabel!
    @IBOutlet weak var buyInfoLabel: UILabel!
    @IBOutlet weak var priceBuyLabel: UILabel!
    @IBOutlet weak var priceSellLabel: UILabel!
    @IBOutlet weak var unitBuyLabel: UILabel!
    @IBOutlet weak var unitSellLabel: UILabel!
    @IBOutlet weak var buyEqualLabel: UILabel!
    @IBOutlet weak var sellEqualLabel: UILabel!
    @IBOutlet weak var validTipInShare: UILabel!
    @IBOutlet weak var validInShare: UILabel!
    @IBOutlet weak var loopringTipLabel: UILabel!
    @IBOutlet weak var productLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var logoImageView: UIImageView!
    
    var tokenSView: TradeViewOnlyViewController = TradeViewOnlyViewController()
    var tokenBView: TradeViewOnlyViewController = TradeViewOnlyViewController()

    // To display QR code
    var qrcodeImageCIImage: CIImage!
    var qrcodeImage: UIImage!

    var order: OriginalOrder?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setBackButton()
        setupShareButton()
        self.view.theme_backgroundColor = ColorPicker.backgroundColor
        self.navigationItem.title = LocalizedString("Order Detail", comment: "")
        
        // TokenView
        tokenSView.view.frame = CGRect(x: 0, y: 0, width: tokenS.frame.width, height: tokenS.frame.height)
        tokenS.addSubview(tokenSView.view)
        tokenSView.view.bindFrameToAnotherView(anotherView: tokenS)
        
        tokenBView.view.frame = CGRect(x: 0, y: 0, width: tokenB.frame.width, height: tokenB.frame.height)
        tokenB.addSubview(tokenBView.view)
        tokenBView.view.bindFrameToAnotherView(anotherView: tokenB)
        
        // Labels
        statusTipLabel.setTitleCharFont()
        statusTipLabel.text = LocalizedString("Status", comment: "")
        statusInfoLabel.setTitleDigitFont()
        
        validTipLabel.setTitleCharFont()
        validTipLabel.text = LocalizedString("Time to Live", comment: "")
        validInfoLabel.setTitleDigitFont()
        
        if let order = self.order {
            setupShareView(order: order)
        }
        
        // Receive order response
        NotificationCenter.default.addObserver(self, selector: #selector(orderResponseReceivedNotification), name: .orderResponseReceived, object: nil)
    }
    
    func setupShareView(order: OriginalOrder) {
        shareImageView.image = UIImage(named: "Share-order")
        logoImageView.image = UIImage(named: "\(Production.getProduct())_share_logo")
        
        titleLabel.theme_textColor = GlobalPicker.contrastTextColor
        titleLabel.text = "Loopring"
        
        if SettingDataManager.shared.getCurrentLanguage().name == "zh-Hans" || SettingDataManager.shared.getCurrentLanguage().name  == "zh-Hant" {
            titleLabel.isHidden = true
            titleImageInShare.isHidden = false
        } else {
            titleLabel.isHidden = false
            titleImageInShare.isHidden = true
        }
        
        sellTipLabel.font = FontConfigManager.shared.getCharactorFont(size: 12)
        sellTipLabel.theme_textColor = GlobalPicker.contrastTextLightColor
        sellTipLabel.text = LocalizedString("Sell", comment: "")
        var length = Asset.getLength(of: order.tokenSell) ?? 4
        sellInfoLabel.font = FontConfigManager.shared.getCharactorFont(size: 12)
        sellInfoLabel.theme_textColor = GlobalPicker.contrastTextColor
        sellInfoLabel.text = order.amountSell.withCommas(length)  + " " + order.tokenSell
        
        buyTipLabel.font = FontConfigManager.shared.getCharactorFont(size: 12)
        buyTipLabel.theme_textColor = GlobalPicker.contrastTextLightColor
        buyTipLabel.text = LocalizedString("Buy", comment: "")
        length = Asset.getLength(of: order.tokenBuy) ?? 4
        buyInfoLabel.font = FontConfigManager.shared.getCharactorFont(size: 12)
        buyInfoLabel.theme_textColor = GlobalPicker.contrastTextColor
        buyInfoLabel.text = order.amountBuy.withCommas(length) + " " + order.tokenBuy
        
        let price = order.amountBuy / order.amountSell
        
        unitBuyLabel.font = FontConfigManager.shared.getCharactorFont(size: 11)
        unitBuyLabel.theme_textColor = GlobalPicker.contrastTextLightColor
        unitBuyLabel.text = "1 \(order.tokenSell)"
        
        priceBuyLabel.font = FontConfigManager.shared.getCharactorFont(size: 11)
        priceBuyLabel.theme_textColor = GlobalPicker.contrastTextColor
        priceBuyLabel.text = "\(price.withCommas()) \(order.tokenBuy)"
        
        unitSellLabel.font = FontConfigManager.shared.getCharactorFont(size: 11)
        unitSellLabel.theme_textColor = GlobalPicker.contrastTextLightColor
        unitSellLabel.text = "1 \(order.tokenBuy)"
        
        priceSellLabel.font = FontConfigManager.shared.getCharactorFont(size: 11)
        priceSellLabel.theme_textColor = GlobalPicker.contrastTextColor
        priceSellLabel.text = "\((1/price).withCommas()) \(order.tokenSell)"
        
        buyEqualLabel.font = FontConfigManager.shared.getCharactorFont(size: 11)
        buyEqualLabel.theme_textColor = GlobalPicker.contrastTextDarkColor
        sellEqualLabel.font = FontConfigManager.shared.getCharactorFont(size: 11)
        sellEqualLabel.theme_textColor = GlobalPicker.contrastTextDarkColor
        
        validTipInShare.font = FontConfigManager.shared.getCharactorFont(size: 11)
        validTipInShare.theme_textColor = GlobalPicker.contrastTextLightColor
        validTipInShare.text = LocalizedString("Time to Live", comment: "")
        let until = DateUtil.convertToDate(UInt(order.validUntil), format: "MM-dd HH:mm")
        validInShare.font = FontConfigManager.shared.getCharactorFont(size: 11)
        validInShare.theme_textColor = GlobalPicker.contrastTextColor
        validInShare.text = until
        
        loopringTipLabel.font = FontConfigManager.shared.getCharactorFont(size: 11)
        loopringTipLabel.theme_textColor = GlobalPicker.contrastTextExtremeLightColor
        loopringTipLabel.text = LocalizedString("Loopring_TIP", comment: "")
        
        productLabel.font = FontConfigManager.shared.getCharactorFont(size: 14)
        productLabel.theme_textColor = GlobalPicker.contrastTextDarkColor
        productLabel.text = Production.getProduct()
        
        urlLabel.font = FontConfigManager.shared.getCharactorFont(size: 12)
        urlLabel.theme_textColor = GlobalPicker.contrastTextColor
        urlLabel.text = Production.getUrlText()
    }

    @objc func orderResponseReceivedNotification() {
        let vc = TradeCompleteViewController()
        vc.order = self.order
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let order = self.order else { return }
        
        tokenSView.update(type: .sell, symbol: order.tokenSell, amount: order.amountSell)
        tokenBView.update(type: .buy, symbol: order.tokenBuy, amount: order.amountBuy)
        
        generateQRCode(order: order)
        let scaleX = qrcodeImageView.frame.size.width / qrcodeImageCIImage.extent.size.width
        let scaleY = qrcodeImageView.frame.size.height / qrcodeImageCIImage.extent.size.height
        let transformedImage = qrcodeImageCIImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        qrcodeImageView.image = UIImage.init(ciImage: transformedImage)
        qrcodeInShare.image = UIImage.init(ciImage: transformedImage)
        
        statusInfoLabel.textColor = .success
        statusInfoLabel.text = LocalizedString("Open", comment: "")
        let since = DateUtil.convertToDate(UInt(order.validSince), format: "MM-dd HH:mm")
        let until = DateUtil.convertToDate(UInt(order.validUntil), format: "MM-dd HH:mm")
        validInfoLabel.text = "\(since) ~ \(until)"
    }
    
    func setupShareButton() {
        let shareButton = UIButton(type: UIButtonType.custom)
        shareButton.setImage(UIImage(named: "ShareButtonImage"), for: .normal)
        shareButton.setImage(UIImage(named: "ShareButtonImage")?.alpha(0.3), for: .highlighted)
        shareButton.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: 8, bottom: 0, right: -8)
        shareButton.addTarget(self, action: #selector(pressedShareButton(_:)), for: UIControlEvents.touchUpInside)
        shareButton.frame = CGRect(x: 0, y: 0, width: 23, height: 23)
        let shareBarButton = UIBarButtonItem(customView: shareButton)
        
        self.navigationItem.rightBarButtonItem = shareBarButton
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    func generateQRCode(order: OriginalOrder) {
        var body = JSON()
        body["type"] = JSON(TradeDataManager.qrcodeType)
        body["value"] = [TradeDataManager.qrcodeHash: order.hash,
                         TradeDataManager.qrcodeAuth: order.authPrivateKey,
                         TradeDataManager.sellRatio: TradeDataManager.shared.sellRatio]
        do {
            if TradeDataManager.qrcodeType == "P2P" {
                guard let data = "loopr-ios://p2p/Hash=\(order.hash)&Ratio=\(TradeDataManager.shared.sellRatio)&Auth=\(order.authPrivateKey)".data(using: .utf8) else { return }
                let ciContext = CIContext()
                if let filter = CIFilter(name: "CIQRCodeGenerator") {
                    filter.setValue(data, forKey: "inputMessage")
                    let transform = CGAffineTransform(scaleX: 10, y: 10)
                    let upScaledImage = filter.outputImage?.transformed(by: transform)
                    qrcodeImageCIImage = upScaledImage!
                    let cgImage = ciContext.createCGImage(upScaledImage!, from: upScaledImage!.extent)
                    qrcodeImage = UIImage(cgImage: cgImage!)
                }
            } else {
                let data = try body.rawData(options: .prettyPrinted)
                let ciContext = CIContext()
                if let filter = CIFilter(name: "CIQRCodeGenerator") {
                    filter.setValue(data, forKey: "inputMessage")
                    let transform = CGAffineTransform(scaleX: 10, y: 10)
                    let upScaledImage = filter.outputImage?.transformed(by: transform)
                    qrcodeImageCIImage = upScaledImage!
                    let cgImage = ciContext.createCGImage(upScaledImage!, from: upScaledImage!.extent)
                    qrcodeImage = UIImage(cgImage: cgImage!)
                }
            }
        } catch let error as NSError {
            print ("Error: \(error.domain)")
        }
    }

    @IBAction func pressedShareButton(_ sender: UIButton) {
        let text = LocalizedString("My Trade QRCode", comment: "")
        let image = UIImage.imageWithView(shareContentView)
        let png = UIImagePNGRepresentation(image)
        let shareAll = [text, png!] as [Any]
        let activityVC = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true, completion: nil)
    }
}
