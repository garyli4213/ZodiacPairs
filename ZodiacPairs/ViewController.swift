//
//  ViewController.swift
//  ZodiacPairs
//
//  Created by Gary Li on 2/3/18.
//  Copyright © 2018 Gary Li. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioPlayerDelegate {
    
    let TAG = "ViewController" //debug trace prefix
    
    //UI components
    @IBOutlet weak var clockLabel: UILabel!
    @IBOutlet weak var labelFlipCounter: UILabel!
    @IBOutlet weak var labelFoundPairs: UILabel!
    @IBOutlet weak var buttonRemember: UIButton!
    @IBOutlet weak var buttonNewGame: UIButton!
    
    //variables for display management
    let numRow = 6 //TODO: to make the number of cards configurable
    let numCol = 4 //
    let marginX = 30
    let marginY = 80
    let cardWidth = 65 //height = 1.35*width
    let cardHeight = 84
    let cardGapX = 20
    let cardGapY = 5
    
    //viewTag starts from a non-zero value and used to identify any UIImageView
    var viewTag = 100
    
    //variables for card management
    var deck: Deck!
    var totalCards: [Card] = []
    
    //variables for game logic management
    var gameOver = false
    var lockCards = false
    var firstCard: Card!
    var secondCard: Card!
    
    //counters
    var rememberCounter = 0
    var flipCounter = 0
    var foundPairs = 0
    
    //timers
    var rememberTimer: Timer!
    var timerWrongCard: Timer!
    
    //audio players for various sounds
    var playerClockTick: AVAudioPlayer!
    var playerCardTapped: AVAudioPlayer!
    var playerFinished: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        print("screen width: \(screenWidth), screen height: \(screenHeight)")
        
        
        
        //prepare sound for clock tick
        var path = Bundle.main.path(forResource: "clock-ticking-1", ofType: "wav")!
        var url = URL(fileURLWithPath: path)
        do {
            playerClockTick = try AVAudioPlayer(contentsOf: url)
            playerClockTick.prepareToPlay()
            playerClockTick.delegate = self //add a delegate to capture finish
        } catch let error as NSError {
            print(error.description)
        }

        //prepare sound for a card tapped
        path = Bundle.main.path(forResource: "flipcard", ofType: "wav")!
        url = URL(fileURLWithPath: path)
        do {
            playerCardTapped = try AVAudioPlayer(contentsOf: url)
            playerCardTapped.prepareToPlay()
        } catch let error as NSError {
            print(error.description)
        }
        
        //prepare sound for a game finished
        path = Bundle.main.path(forResource: "finish", ofType: "wav")!
        url = URL(fileURLWithPath: path)
        do {
            playerFinished = try AVAudioPlayer(contentsOf: url)
            playerFinished.prepareToPlay()
        } catch let error as NSError {
            print(error.description)
        }
        
        //initialize a game anyway when the app is firstly loaded
        newGame()
    }

    @IBAction func newGameClicked(_ sender: UIButton) {
        playerCardTapped.play() //play a soound
        clearGame()
        newGame() //initialize all variables for a fresh game
    }
    
    func newGame() {
        print("newGame()")
        //clear game control vairables
        gameOver = false
        lockCards = false
        
        //clear first and second cards
        firstCard = nil
        secondCard = nil
        
        //clear counters and their displays
        flipCounter = 0
        labelFlipCounter.text = "\(flipCounter)"
        foundPairs = 0
        labelFoundPairs.text = "\(foundPairs)"
        
        //enable remember button at begining (it will be disabled once used)
        buttonRemember.isEnabled = true
        
        deck = Deck() //create a group of cards ready for use
        
        //TODO: make the number of cards configurable
        for row in 0..<numRow {
            for col in 0..<numCol {
                 //pull out a card from deck
                if let card = deck.drawCard() {
                    addCard(card: card, cardRow: row, cardCol: col, isFaceUp:false)
                    totalCards.append(card) //add the card into an array for future use
                }
                else {
                    print("drawCard() failed to get a card")
                    return
                }
            }
        }
        
        //flip all cards face down
        for index in 0..<totalCards.count {
            updateImage(tag: totalCards[index].getViewTag(),image: "backcard")
        }
    }
    
    @IBAction func rememberClicked(_ sender: UIButton) {
        playerCardTapped.play() //play a sound
        
        //make all cards face up for a given time, say 10s
        for index in 0..<totalCards.count {
            updateImage(tag: totalCards[index].getViewTag(),image: totalCards[index].getImageName())
        }
        rememberCounter = 10 //TODO: make it configurable
        clockLabel.text = "\(rememberCounter)"
        //start a timer and flip all cards face down at timeout
        rememberTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.rememberTimerProc), userInfo: nil, repeats: true)
        //start ticking sound
        if playerClockTick.isPlaying == false {
            playerClockTick.play()
        }
    }
    
    // flip all cards face down when rememberTimer times out
    @objc func rememberTimerProc() {
        if (rememberTimer != nil) {
            rememberCounter -= 1 //timer decrement by 1s
            //update timer display
            print("rememberCounter = \(rememberCounter)")
            clockLabel.text = "\(rememberCounter)"
            //if timeout, flip all cards face down and kill the timer
            if (rememberCounter == 0) {
                buttonRemember.isEnabled = false //disable remember button until next game
                rememberTimer.invalidate()
                rememberTimer = nil
                //flip all cards face down
                for index in 0..<totalCards.count {
                    updateImage(tag: totalCards[index].getViewTag(),image: "backcard")
                }
                playerClockTick.stop() //stop clock ticking
            }
        }
    }
   
    //if clock ticking sound finished, restart it during remembering period
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool){
        print(flag)
        if flag == true && player.isPlaying == false {
            player.play() //play again if finished before being stopped
        }
    }
    
    //tap event handler (if any card has been tapped)
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        print("imageTapped")

        if gameOver == false && lockCards == false { //process this event only when game is not over
            //get the UIImage user tapped
            let tappedImage = tapGestureRecognizer.view as! UIImageView
            let tag = tappedImage.tag //get UIImage tag with which to get the card instance
            //tag starts from a non-zero value 100, then convert it to a zero started index
            let card = totalCards[tag - 100]
            if card.isFaceUp == false { //the card has been faced down
                //update flip counter
                flipCounter += 1
                labelFlipCounter.text = "\(flipCounter)"
                
                updateImage(tag:tag, image: card.getImageName())
                playerCardTapped.play() //play a sound of a card tapped
                if firstCard == nil { //no card has been selected
                    firstCard = card
                    if firstCard.isFaceUp == false {
                        updateImage(tag: firstCard.getViewTag(),image: firstCard.getImageName())
                    }
                }
                else if secondCard == nil { //second card has not been selected yet
                    lockCards = true //don't allow any more card to be fliped before delay timeout
                    
                    secondCard = card
                    if secondCard.isFaceUp == false {
                        updateImage(tag: secondCard.getViewTag(),image: secondCard.getImageName())
                        if firstCard.getZodiac() != secondCard.getZodiac() {
                            //cards' content don't match
                            print("wrong card")
                            //TODO: start wrong card timer 2s
                            if timerWrongCard == nil {
                                timerWrongCard = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.timerWrongCardProc), userInfo: nil, repeats: false)
                            }
                        }
                        else {
                            //both cards match
                            firstCard = nil
                            secondCard = nil //clear cards prepare for next
                            print("both cards match")
                            
                            foundPairs += 1
                            labelFoundPairs.text = "\(foundPairs)"
                            
                            if (foundPairs == totalCards.count/2) {
                                print("game over")
                                gameOver = true;
                                playerFinished.play()
                                
                            }
                            lockCards = false
                        }
                    }
                }
                else { //second card already selected
                    //do nothing
                    print("the second card already been selected")
                }
            }
            else {
                //do nothing if the card has already faced up
                print("a card already faced up")
            }
        }
        else {
            print("invalid action, since lockCards is on or game is over")
        }
    }
    
    //if two cards don't match, delay a while, and flip the cards face down
    @objc func timerWrongCardProc() {
        print("timerWrongCardProc()")
        //stop timer
        timerWrongCard.invalidate()
        timerWrongCard = nil
        //flip both cards face down
        updateImage(tag: firstCard.getViewTag(),image: "backcard")
        updateImage(tag: secondCard.getViewTag(),image: "backcard")
        //clear the first and second cards
        firstCard = nil
        secondCard = nil
        //release lock to allow cards to be tapped
        lockCards = false
    }

    //operations to create a new card
    private func addCard(card: Card, cardRow: Int, cardCol: Int, isFaceUp: Bool) {
        var image: UIImage
        
        card.isFaceUp = isFaceUp //remember the card face up
        if isFaceUp { //if face up, use the card image
            image = UIImage(named: card.imageName)!
        }
        else { //if face down, use backcard image
            image = UIImage(named: "backcard")!
            print("image width: \(image.size.width), image height: \(image.size.height)")
        }
        let imageView: UIImageView = UIImageView(image: image) //create an image view to hold the image
        imageView.tag = viewTag //set the view tag for future retrieval
        card.setViewTag(tag: viewTag) //remember the viewTag in Card instance
        viewTag += 1 //increment tag value for next image view
        imageView.contentMode = .scaleAspectFill //fill the card image size into specified demension
        imageView.frame.size = CGSize(width:cardWidth, height:cardHeight) //set the size of image view
        let cardPosX = marginX + (cardWidth+cardGapX)*cardCol
        let cardPosY = marginY + (cardHeight+cardGapY)*cardRow
        imageView.frame.origin = CGPoint(x:cardPosX, y:cardPosY) //set starting point of the imageview in root UIView
        
        //add a callback to capture tapping event for the UIImage
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGesture)
        //add image view into root UIView, which makes the image visible
        self.view.addSubview(imageView)
    }

    //removed all cards from screen and release them from totalCards
    //called only when the number of cards is changed, and a group of cards
    //is drew from deck and saved in totalCards
    func clearGame() {
        //TODO: remove all UIImageViews on the board
        print("clearGame()")
        print("totalCards = \(totalCards.count)")
        for index in 0..<totalCards.count {
            //remove UIImageView from root view one by one
            let tag = 100 + index
            if let viewWithTag = self.view.viewWithTag(tag) as? UIImageView {
                viewWithTag.removeFromSuperview()
            }
            //return all cards to deck one by one
            let card = totalCards[index]
            deck.returnCard(card: card)
        }
    }
    
    func updateImage (tag: Int, image: String) {
        if viewTag > 100 { //some cards have been shown in UIView
            if let viewWithTag = self.view.viewWithTag(tag) as? UIImageView {
                viewWithTag.image = UIImage(named: image)!
            }
            else{
                print("Nil view")
            }
        }
        else {
            print("invalid image tag")
        }
    }
}

