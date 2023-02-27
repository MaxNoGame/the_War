//
//  MainViewModel.swift
//  CombineURLCardsMvvm
//
//  Created by Maksym Ponomarchuk on 30.01.2023.
//

import UIKit
import Combine

class MainViewModel {
    
    var networkLayer = NetworkLayer()
    var game = GameRound()
    var deckShuffledPublisher = PassthroughSubject<Void, Never>()
    var shuffledCards: ShuffleTheCards?
    var cards = [CardJson]()
    
    func getNewCards() {
        let prefix = "https://deckofcardsapi.com/api/deck/"
        guard let id = shuffledCards?.deck_id else {return}
        let postfix = "/draw/?count=52"
        guard let url = URL(string: prefix + id + postfix) else {return}
        networkLayer.fetchCard(url: url) { card in
            self.cards = card
            self.game.isDeckEmpty = false
        }
    }
    
    func shuffleTheCards() {
        // START SHUFFLED SOUND HERE
        game.removePlayersCards()
        guard let url = URL(string: "https://deckofcardsapi.com/api/deck/new/shuffle/?deck_count=1") else {return}
        networkLayer.getNewDeck(url: url) { shuffled in
            self.shuffledCards = shuffled
            self.deckShuffledPublisher.send()
            self.getNewCards()
        }
    }
    
    func deckTapped() {
        if !game.isDeckEmpty {
            game.giveCardsPlayers(cards: cards) {
                game.isDeckEmpty = true
            }
        }
    }
    
    func playerTapped() {
        game.makeMove()
    }
}
