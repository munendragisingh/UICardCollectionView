//
//  UICardCollectionView.swift
//  CardView
//
//  Created by Munendra Pratap Singh on 29/05/18.
//  Copyright © 2018 Munendra Pratap Singh. All rights reserved.
//

import UIKit

protocol UICardCollectionViewDataSource {
    func UICardCollectionView(numberOfCardFor:UICardCollectionView)->Int
    func UICardCollectionView(cardCollectionView:UICardCollectionView, frameForCardAt index:Int)->CGRect
    func UICardCollectionView(cardCollectionView:UICardCollectionView, cardAt index:Int)->UICardView
}

protocol UICardCollectionViewDelegate {
    func UICardViewMovingLeft(card:UICardView, with distance:CGFloat)
    func UICardViewDidMovingRight(card:UICardView, with distance:CGFloat)
    
    func UICardView(cardCollectionView:UICardCollectionView, didMovingLeft card:UICardView)
    func UICardView(cardCollectionView:UICardCollectionView, didMovingRight card:UICardView)
}

class UICardCollectionView: UIView {
    
    var identification:String?
    var dataSource:UICardCollectionViewDataSource?
    var delegste:UICardCollectionViewDelegate?
    
    private var cardArray = Array<UICardView>()
    private var numberOfCard:Int?
    private var lastIndex = 0
    private var totalCards = 0
    private var visibleIndex:Int?
    @IBOutlet weak var smileEmoji: UIImageView!
    @IBOutlet weak var sadEmoji: UIImageView!
    
    @IBOutlet weak var sadX: NSLayoutConstraint!
    @IBOutlet weak var sadHeight: NSLayoutConstraint!
    @IBOutlet weak var sadWidth: NSLayoutConstraint!
    
    @IBOutlet weak var smileX: NSLayoutConstraint!
    @IBOutlet weak var smileHeight: NSLayoutConstraint!
    @IBOutlet weak var smileWidth: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func reloadData()  {
        numberOfCard = dataSource?.UICardCollectionView(numberOfCardFor: self)
        totalCards = numberOfCard!
        var temp = 0
        if numberOfCard! >= 3{
            temp = 3
        }else{
            temp = numberOfCard!
        }
        for i in 0 ..< temp {
            let card = dataSource?.UICardCollectionView(cardCollectionView: self, cardAt: i)
            lastIndex = lastIndex + 1
            card?.delegate = self
            self.insertSubview(card!, at: 0)
            card?.setUpInitData()
            cardArray.insert(card!, at: 0)
        }
        self.bringSubview(toFront: smileEmoji)
        self.bringSubview(toFront: sadEmoji)
    }
    
    func deQueueCard(with identification:String, index:Int)-> UICardView {
        let frame = dataSource?.UICardCollectionView(cardCollectionView: self, frameForCardAt: index)
        let cardView:UICardView?
        if lastIndex >= 3{
            cardView = cardArray[0]
            cardView?.frame = frame!
            //cardView?.resetCardViewToOriginalPosition();
            
        }else{
            cardView = UICardView(frame: frame!)
        }
        cardView?.identification = identification
        cardView?.index = index
        cardView?.tag = index + 1
        if index % 2 == 0{
            cardView?.backgroundColor = UIColor.green
        }else{
            cardView?.backgroundColor = UIColor.yellow
        }
        //cardView?.backgroundColor = .clear
        return cardView!
    }
    
    func card(at index:Int) -> UICardView {
        return self.viewWithTag(index + 1 ) as! UICardView
    }
    
    func resetEmoji()  {
        sadEmoji.alpha = 0
        smileEmoji.alpha = 0
        sadX.constant =  0
        sadHeight.constant = 70
        sadWidth.constant = 70
        
        smileX.constant =  0
        smileHeight.constant = 70
        smileWidth.constant = 70
    }
}

extension UICardCollectionView: UICardViewDelegate{
   
    func UICardViewReset(card:UICardView){
        resetEmoji()
        UIView.animate(withDuration: 0.2) {
            self.layoutIfNeeded()
        }
    }
    
    func UICardViewMovingLeft(card:UICardView, with distance:CGFloat){
        smileEmoji.alpha = abs(distance)/self.center.x
        sadEmoji.alpha = 0
        print("smileEmoji.center.x:\(smileEmoji.center.x)      self.center.x:\(self.center.x)")
        if smileEmoji.center.x >= self.center.x{
            smileX.constant =  distance
            smileHeight.constant = distance + 70
            smileWidth.constant = distance + 70
        }
        self.delegste?.UICardViewMovingLeft(card: card, with: distance)
    }
    
    func UICardViewDidMovingRight(card:UICardView, with distance:CGFloat){
        sadEmoji.alpha = abs(distance)/self.center.x
        smileEmoji.alpha = 0
        if sadEmoji.center.x <= self.center.x{
            sadX.constant =  distance
            sadHeight.constant = distance + 70
            sadWidth.constant = distance + 70
        }
        self.delegste?.UICardViewDidMovingRight(card: card, with: distance)
    }
    
    func UICardViewDidMovedLeft(card:UICardView){
        resetEmoji()
        self.manageCard(card: card)
        self.delegste?.UICardView(cardCollectionView: self, didMovingLeft: card)
    }
    
    func UICardViewDidMovedRight(card:UICardView){
        resetEmoji()
        self.manageCard(card: card)
        self.delegste?.UICardView(cardCollectionView: self, didMovingLeft: card)
    }
    
    func manageCard(card:UICardView) {
        totalCards = totalCards - 1
        if lastIndex < numberOfCard! && totalCards > 3{
            lastIndex = lastIndex + 1
            let card = self.dataSource?.UICardCollectionView(cardCollectionView: self, cardAt: lastIndex)
//            let card = cardArray[0]
            cardArray.remove(at: 0)
            cardArray.append(card!)
            self.insertSubview(card!, at: 0)
        }else{
            card.removeFromSuperview()
        }
    }
}
