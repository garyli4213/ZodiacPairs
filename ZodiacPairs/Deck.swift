//
//  Deck.swift
//  ZodiacPairs
//
//  Created by Gary Li on 1/3/18.
//  Copyright © 2018 Gary Li. All rights reserved.
//

import Foundation

class Deck {
    //debug
    let TAG = "Deck"
    //deck collection
    
    var totalCards: [Card] = []
    
    init () {
        
        //generate total cards in a set (12*2 = 24 cards)
        var index = 0
        for zodiac in Zodiacs.allValues {
            let cardFile = zodiac.rawValue
            print(cardFile)
            var card = Card(Zodiac: zodiac.rawValue, Image: cardFile)
            totalCards.append(card) //add an original card
            print(totalCards[index])
            index += 1
            card = card.copy()
            totalCards.append(card) //add a duplicated card
            print(totalCards[index])
            index += 1
        }
        //shuffle cards
        for idx in 0..<totalCards.count {
            print("shuffle card \(idx)")
            let victim = Int(arc4random_uniform(UInt32(totalCards.count)))
            print("victim = \(victim)")
            let temp: Card = totalCards[victim]
            totalCards[victim] = totalCards[idx]
            totalCards[idx] = temp;
        }
    }
    
        
    func getTotalCards() -> Int{
        return totalCards.count
    }
    
    func drawCard() -> Card? {
        if totalCards.count > 0 {
            let card = totalCards.remove(at: (totalCards.count-1))
            //print("retrieve "+card.toString())
            return card
        }
        else {
            return nil
        }
    }
/*
    //get multiple cads
    func drawCards(numCards: Int) -> [Card] {
        //TODO: if totalCards.size() >= numCards, then return numCards
        var ret: [Card] = []
        for j in 0...numCards {
            if let ret[j] = drawCard()
        }
        print("remaining cards \(totalCards.count)")
        return ret
    }
 */
    func returnCard(card: Card) {
        totalCards.append(card)        
    }
}
        
