//
//  RatingBar.swift
//  lab2FilmInfo
//
//  Created by Adrian Chizhevskyi on 17.12.2020.
//

import UIKit


class RatingBar: UIView {
    
    var currentTime:Double = 0
    var previousProgress:Double = 0
    
    //MARK: awakeFromNib

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
        label.text = "0"
        labelPercent.text = "%"
    }
    
    
    //MARK: Public
    
    public var lineWidth:CGFloat = 15 {
        didSet{
            foregroundLayer.lineWidth = lineWidth
            backgroundLayer.lineWidth = lineWidth - (0.20 * lineWidth)
        }
    }
    
    public var labelSize: CGFloat = 30 {
        didSet {
            label.font = UIFont.systemFont(ofSize: labelSize)
            label.sizeToFit()
            configLabel()
        }
    }
    
    public var labelPercentSize: CGFloat = 10 {
        didSet {
            labelPercent.font = UIFont.systemFont(ofSize: labelPercentSize)
            labelPercent.sizeToFit()
            configLabelPercent()
        }
    }
    

    
    public var safePercent: Int = 100 {
        didSet{
            setForegroundLayerColorForLowPercent()
        }
    }
    
    public var progress: Double = 0
    public func setProgress(to progressConstant: Double, withAnimation: Bool, endProgress: Double) {
        
        var progress: Double {
            get {
                if progressConstant > endProgress { return endProgress }
                else if progressConstant < 0 { return 0 }
                else { return progressConstant }
            }
        }
        
        foregroundLayer.strokeEnd = CGFloat(progress)
        
        if withAnimation {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = previousProgress
            animation.toValue = progress
            animation.duration = 1.5
            foregroundLayer.add(animation, forKey: "foregroundAnimation")
            
        }
        
        
        previousProgress = progress
        currentTime = 0
        
        DispatchQueue.main.async {
            self.label.text = "\(Int(progress * 100))"
            if progress<=0.25 {
            self.setForegroundLayerColorForLowPercent()
        }
            else if progress<=0.5 {
            self.setForegroundLayerColorForMediumPercent()
        }
            else if progress<=0.75 {
            self.setForegroundLayerColorForHighPercent()
        }
            else {
            self.setForegroundLayerColorForPerfectPercent()
            }
            
            self.configLabel()
            self.configLabelPercent()
        }
        
    }
    
    
    
    
    //MARK: Private
    private var label = UILabel()
    private var labelPercent = UILabel()
    private let foregroundLayer = CAShapeLayer()
    private let backgroundLayer = CAShapeLayer()
    
    private var radius: CGFloat {
        get{
            if self.frame.width < self.frame.height { return (self.frame.width - lineWidth)/2 }
            else { return (self.frame.height - lineWidth)/2 }
        }
    }
    
    private var pathCenter: CGPoint{ get{ return self.convert(self.center, from:self.superview) } }
    private func makeBar(){
        self.layer.sublayers = nil
        drawBackgroundLayer()
        drawForegroundLayer()
    }
    
    private func drawBackgroundLayer(){
        let path = UIBezierPath(arcCenter: pathCenter, radius: self.radius, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
        self.backgroundLayer.path = path.cgPath
        self.backgroundLayer.strokeColor = UIColor(red: 20.0/255.0, green: 20.0/255.0, blue: 20.0/255.0, alpha: 1.0).cgColor
        self.backgroundLayer.lineWidth = lineWidth+5
        self.backgroundLayer.fillColor = UIColor.white.cgColor
        self.layer.addSublayer(backgroundLayer)
        
    }
    
    private func drawForegroundLayer(){
        
        let startAngle = (-CGFloat.pi/2)
        let endAngle = 2 * CGFloat.pi + startAngle
        
        let path = UIBezierPath(arcCenter: pathCenter, radius: self.radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        foregroundLayer.lineCap = CAShapeLayerLineCap.round
        foregroundLayer.path = path.cgPath
        foregroundLayer.lineWidth = lineWidth
        foregroundLayer.fillColor = UIColor.clear.cgColor
        
        //foregroundLayer.strokeColor = UIColor(red: 200.0/255.0, green: 22.0/255.0, blue: 0.0/255.0, alpha: 1.0).cgColor
        //foregroundLayer.strokeEnd = 0
        
        self.layer.addSublayer(foregroundLayer)
        
    }
    
    
    
    private func makeLabel(withText text: String) -> UILabel {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        label.text = text
        label.font = UIFont.systemFont(ofSize: labelSize)
        label.sizeToFit()
        label.center = CGPoint(x: pathCenter.x, y: pathCenter.y)
        return label
    }
    
    private func makeLabelPercent(withText text: String) -> UILabel {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        label.text = text
        label.font = UIFont.systemFont(ofSize: labelPercentSize)
        label.sizeToFit()
        label.textColor = UIColor.lightGray
        label.center = CGPoint(x: pathCenter.x + (label.frame.size.width/2) + 10, y: pathCenter.y)
        return label
    }
    
    private func configLabel(){
        label.textColor = UIColor(red: 80.0/255.0, green: 80.0/255.0, blue: 80.0/255.0, alpha: 1.0)
        label.sizeToFit()
        label.center = CGPoint(x: pathCenter.x, y: pathCenter.y)
    }
    
    private func configLabelPercent(){
        labelPercent.textColor = UIColor(red: 80.0/255.0, green: 80.0/255.0, blue: 80.0/255.0, alpha: 0.4)
        labelPercent.sizeToFit()
        labelPercent.center = CGPoint(x: pathCenter.x + (label.frame.size.width/2) + 10, y: pathCenter.y)
    }
    
    
    private func setForegroundLayerColorForLowPercent(){
        self.foregroundLayer.strokeColor = UIColor(red: 200.0/255.0, green: 20.0/255.0, blue: 30.0/255.0, alpha: 1.0).cgColor
    }
    
    private func setForegroundLayerColorForMediumPercent(){
        self.foregroundLayer.strokeColor = UIColor(red: 225.0/255.0, green: 140.0/255.0, blue: 20.0/255.0, alpha: 1.0).cgColor
    }
    
    private func setForegroundLayerColorForHighPercent(){
        self.foregroundLayer.strokeColor = UIColor(red: 220.0/255.0, green: 180.0/255.0, blue: 15.0/255.0, alpha: 1.0).cgColor
    }
    
    private func setForegroundLayerColorForPerfectPercent(){
        self.foregroundLayer.strokeColor = UIColor(red: 20.0/255.0, green: 250.0/255.0, blue: 30.0/255.0, alpha: 1.0).cgColor
    }
    
    private func setupView() {
        makeBar()
        self.addSubview(label)
        self.addSubview(labelPercent)
    }
    
    
    
    //Layout Sublayers

    private var layoutDone = false
    override func layoutSublayers(of layer: CALayer) {
        if !layoutDone {
            let tempText = label.text
            setupView()
            label.text = tempText
            layoutDone = true
        }
    }
}
