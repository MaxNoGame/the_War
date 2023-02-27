//
//  GameRound.swift
//  CombineURLCardsMvvm
//
//  Created by Maksym Ponomarchuk on 31.01.2023.
//

import UIKit
import Combine

class GameRound {
    var player = Player()
    var computer = Computer()
    var network = NetworkLayer()
    @Published var currentPlayerCard: UIImage?
    @Published var currentComputerCard: UIImage?
    @Published var isDeckEmpty = true
    var whoWon = PassthroughSubject<TypeBattleWin, Never>()
    var gameWinner = PassthroughSubject<TypeBattleWin, Never>()
    var currentBattleCards = [CardJson](){
        didSet{
            //print("CurrentBatllCards: ", currentBattleCards)
        }
    }
    let cardValues = ["2":1, "3":2, "4":3 , "5":4, "6":5, "7":6, "8":7,"9":8, "10":9, "JACK":10, "QUEEN":11, "KING":12, "ACE":13]
    
    func startRound() {
        
    }
    
    func giveCardsPlayers(cards: [CardJson], completion: ()->()) {
        let half = cards.count / 2
        let playerCards = cards[0..<half]
        let compCards = cards[half...(cards.count-1)]
        player.cards = Array(playerCards)
        computer.cards = Array(compCards)
//        player.cards = Array(playerCards).sorted{$0.value < $1.value}
//        computer.cards = Array(compCards).sorted{$0.value < $1.value}
        
//        player.cards.append(CardJson(image: "", value: "10", suit: "CLUBS"))
//        player.cards.append(CardJson(image: "", value: "10", suit: "CLUBS"))
//        computer.cards.append(CardJson(image: "", value: "2", suit: "CLUBS"))
//        computer.cards.append(CardJson(image: "", value: "2", suit: "CLUBS"))
        currentBattleCards.removeAll()
        completion()
    }
    
    func makeMove() {
        guard let playersCard = player.cards.last else {return}
        player.cards.removeLast()
        currentBattleCards.append(playersCard)
        guard let computersCard = computer.cards.last else {return}
        computer.cards.removeLast()
        currentBattleCards.append(computersCard)
        network.getPicture(stringUrl: playersCard.image, completion: { image in
            DispatchQueue.main.async {
                guard let image = image else {
                    self.currentPlayerCard = UIImage(named: playersCard.value)
                    return
                }
                self.currentPlayerCard = image
            }
        })
        network.getPicture(stringUrl: computersCard.image, completion: { image in
            DispatchQueue.main.async {
                guard let image = image else {self.currentComputerCard = UIImage(named: computersCard.value); return}
                self.currentComputerCard = image
            }
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [self] in
            switch isPlayerWinBattle(playersCard: playersCard, computersCard: computersCard) {
            case .playerWin:
                player.cards.insert(contentsOf: currentBattleCards, at: 0);
                currentBattleCards.removeAll();
                whoWon.send(.playerWin)
            case .computerWin:
                computer.cards.insert(contentsOf: currentBattleCards, at: 0);
                currentBattleCards.removeAll();
                whoWon.send(.computerWin)
            case .noWinner:
                whoWon.send(.noWinner)
                //currentBattleCards.append(contentsOf: [playersCard, computersCard])
            }
        }
        if player.cards.isEmpty {gameWinner.send(.computerWin)}
        if computer.cards.isEmpty {gameWinner.send(.playerWin)}
    }
    
    func isPlayerWinBattle(playersCard: CardJson, computersCard: CardJson) -> TypeBattleWin {
        if cardValues[playersCard.value]! > cardValues[computersCard.value]! {
            return .playerWin
        } else if cardValues[playersCard.value]! < cardValues[computersCard.value]! {
            return .computerWin
        } else {
            return .noWinner
        }
    }
    
    
//    func playerWin() {
//        print("player win")
//        removePlayersCards()
//    }
//    
//    func computerWin() {
//        print("computer win")
//        removePlayersCards()
//    }
    
    func removePlayersCards() {
        player.cards.removeAll()
        computer.cards.removeAll()
    }
    
    func endRound() {
        
    }
}




class Player {
    @Published var cards = [CardJson](){
        didSet{
            //print("Player last card: ", cards.last ?? nil)
        }
    }
}

class Computer {
    @Published var cards = [CardJson](){
        didSet{
            //print("Comp last card: ", cards.last ?? nil)
        }
    }
}

enum TypeBattleWin {
    case playerWin
    case computerWin
    case noWinner
}
