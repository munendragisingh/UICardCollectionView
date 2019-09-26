//
//  UICardView.swift
//  CardView
//
//  Created by Munendra Pratap Singh on 29/05/18.
//  Copyright © 2018 Munendra Pratap Singh. All rights reserved.
//

import UIKit

protocol UICardViewDelegate {
    func UICardViewMovingLeft(card:UICardView, with distance:CGFloat)
    func UICardViewDidMovingRight(card:UICardView, with distance:CGFloat)
    
    func UICardViewDidMovedLeft(card:UICardView)
    func UICardViewDidMovedRight(card:UICardView)
    
    func UICardViewReset(card:UICardView)
}

class UICardView: UIView {
    
    private var divisionParam: CGFloat!
    private var initialCenter:CGPoint?
    private var angle:CGFloat?
    var delegate:UICardViewDelegate?
    var identification:String?
    var index:Int?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizer(_:)))
        pan.maximumNumberOfTouches = 1
        self.addGestureRecognizer(pan)
    }
    
    func setUpInitData() {
        divisionParam = ((self.superview?.frame.size.width)!/2)/0.61
        initialCenter = self.center
        angle = CGFloat(arc4random_uniform(10)) * CGFloat(Double.pi / 180)
        self.transform = CGAffineTransform.identity.rotated(by: angle!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func panGestureRecognizer(_ sender: UIPanGestureRecognizer) {
        let cardView = sender.view!
        let translationPoint = sender.translation(in: self.superview)
        cardView.center = CGPoint(x: (self.superview?.center.x)! + translationPoint.x, y: (initialCenter?.y)!)
        
        let distanceMoved = cardView.center.x - (initialCenter?.x)!
        //print("\(distanceMoved)     ")
        if distanceMoved > 0 {
//            smileImageView.alpha = abs(distanceMoved)/view.center.x
//            sadImageView.alpha = 0
            self.delegate?.UICardViewDidMovingRight(card: self, with: distanceMoved)
        } else {
            self.delegate?.UICardViewMovingLeft(card: self, with: -distanceMoved)
        }
        
        cardView.transform = CGAffineTransform(rotationAngle: distanceMoved/divisionParam)
        if sender.state == UIGestureRecognizerState.ended {
            if cardView.center.x < 20 { // Moved to left
                self.moveLeft(cardView: cardView)
                return
            } else if (cardView.center.x > ((self.superview?.frame.size.width)!-20)) { // Moved to right
                self.moveRight(cardView: cardView)
                return
            }
            UIView.animate(withDuration: 0.2, animations: {
                self.resetCardViewToOriginalPosition()
            })
        }
    }
    
    @objc func moveRightByClick() {
        UIView.animate(withDuration: 0.4, animations: {
            self.transform = CGAffineTransform(rotationAngle:CGFloat(60 * Double.pi / 180))
        })
        UIView.animate(withDuration: 0.4, animations: {
            self.center = CGPoint(x: self.center.x + 400, y: self.center.y)
        }) { (status) in
            //self.removeFromSuperview()
        }
    }
    
    @objc func moveLeftByClick() {
        UIView.animate(withDuration: 0.4, animations: {
            self.transform = CGAffineTransform(rotationAngle: CGFloat(-60 * Double.pi / 180))
        })
        UIView.animate(withDuration: 0.4, animations: {
            self.center = CGPoint(x: self.center.x - 400, y: self.center.y)
        }) { (status) in
            //self.removeFromSuperview()
        }
    }
    
   private func moveRight(cardView:UIView){
        UIView.animate(withDuration: 0.4, animations: {
            cardView.center = CGPoint(x: cardView.center.x+200, y: cardView.center.y)
        }) { (status) in
            self.delegate?.UICardViewDidMovedRight(card: self)
            //self.removeFromSuperview()
        }
    }
    
   private func moveLeft(cardView:UIView){
        UIView.animate(withDuration: 0.4, animations: {
            cardView.center = CGPoint(x: cardView.center.x-200, y: cardView.center.y)
        }) { (status) in
            self.delegate?.UICardViewDidMovedLeft(card: self)
            //self.removeFromSuperview()
        }
    }
    
    func resetCardViewToOriginalPosition(){
        self.center = (initialCenter)!
        self.delegate?.UICardViewReset(card: self)
        self.transform = CGAffineTransform.identity.rotated(by: angle!)
        self.transform = .identity
    }
}
