//
//  Card.swift
//  ZodiacPairs
//
//  Created by Gary Li on 1/3/18.
//  Copyright © 2018 Gary Li. All rights reserved.
//

import Foundation

enum Zodiacs: String {
    case mouse = "mouse"
    case cow = "cow"
    case tiger = "tiger"
    case rabbit = "rabbit"
    case dragon = "dragon"
    case snake = "snake"
    case horse = "horse"
    case sheep = "sheep"
    case monkey = "monkey"
    case chicken = "chicken"
    case dog = "dog"
    case pig = "pig"
    static let allValues = [mouse,cow,tiger,rabbit,dragon,snake,horse,sheep,monkey,chicken,dog,pig]
}


class Card {
    var TAG = "Card"
    var zodiac: String
    var isFaceUp: Bool = true
    var imageName: String
    var viewTag: Int = 0
        
    init (Zodiac zodiac: String, Image imageName: String) {
        //print("suit: "+suits[suit]+", rank: "+ranks[rank])
        self.zodiac=zodiac
        self.imageName = imageName
        print(zodiac + "," + imageName)
    }
    
    
    func copy() -> Card {
        let newCard: Card = Card(Zodiac: zodiac, Image: imageName)
        return newCard
    }
    
    func getZodiac() ->String {
        return self.zodiac
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
    
    //TODO: set isFaceUp value/property?
}
