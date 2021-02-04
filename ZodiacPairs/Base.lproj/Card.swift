//
//  Card.swift
//  BlackJack
//
//  Created by Gary Li on 1/3/18.
//  Copyright © 2018 Gary Li. All rights reserved.
//

import Foundation

class Card {
    var TAG = "Card"
    var rank: Int
    var suit: Int
    var isFaceUp: Bool = true
    var imageName: String
    var viewTag: Int = 0

    
    var suits = ["clubs","spades", "hearts", "diamonds"]
    var ranks  = ["a", "2", "3", "4", "5", "6", "7", "8", "9", "10", "j", "q", "k" ]
    
    init (cardSuit suit: Int, cardRank rank: Int, cardImage img: String) { 
        //print("suit: "+suits[suit]+", rank: "+ranks[rank])
        self.rank=rank
        self.suit=suit
        self.imageName = img
        print(self.toString()+","+img)
    }
    
    func rankAsString(rank: Int ) -> String {
        return "" //ranks[rank]
    }
    
    func toString() -> String {
        return suits[suit] + "_" + ranks[rank]
    }
    
    func copy() -> Card {
        let newCard: Card = Card(cardSuit: suit, cardRank: rank, cardImage: imageName)
        return newCard
    }
    
    func getRank() ->Int {
        return self.rank
    }
    func getSuit() ->Int {
        return self.suit
    }
    func getImageName() -> String {
        return self.imageName
    }    
    func getViewTag() -> Int {
        return self.viewTag
    }
    func setViewTag(tag: Int) {
        self.viewTag = tag
    }
   
}
