//
//  ViewController.swift
//  CombineURLCardsMvvm
//
//  Created by Maksym Ponomarchuk on 30.01.2023.
//

import UIKit
import Combine

class ViewController: UIViewController {
    
    var viewModel = MainViewModel()
    var cancellable: AnyCancellable?
    var winStatusCancellable: AnyCancellable?
    var gameWinnerStatus: AnyCancellable?
    private var deckEmpty: AnyCancellable?
    private var playerCards: AnyCancellable?
    private var computerCards: AnyCancellable?
    private var playerCardImage: AnyCancellable?
    private var computerCardImage: AnyCancellable?
    let tapOnDeck = UITapGestureRecognizer()
    
    @IBOutlet weak var shuffleButton: UIButton!
    @IBOutlet weak var deckOfCards: UIImageView!
    @IBOutlet weak var playerHiddenCards: UIImageView!
    @IBOutlet weak var playerOpenCard: UIImageView!
    @IBOutlet weak var compHiddenCards: UIImageView!
    @IBOutlet weak var compOpenCard: UIImageView!
    @IBOutlet weak var computerView: UIView!
    @IBOutlet weak var compLabel: UILabel!
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var playerLabel: UILabel!
    @IBOutlet weak var upStack: UIStackView!
    @IBOutlet weak var midStack: UIStackView!
    @IBOutlet weak var buttonStack: UIStackView!
    let tempPlayerCard = UIImageView()
    let tempComputerCard = UIImageView()
    
    var isAnimating = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //bindViewModel()
        bindGame()
        setupGestureTaps()
        setupDesign()
    }
    
    func setupDesign() {
        view.backgroundColor = Constants.backgroundFieldColor
        playerView.backgroundColor = Constants.backgroundFieldColor
        computerView.backgroundColor = Constants.backgroundFieldColor
        playerOpenCard.layer.zPosition = 1
        compOpenCard.layer.zPosition = 1
        deckOfCards.layer.borderWidth = 1
        deckOfCards.layer.cornerRadius = deckOfCards.frame.width / 20
        deckOfCards.layer.borderColor = .init(gray: 0, alpha: 1)
        compHiddenCards.layer.borderWidth = 1
        compHiddenCards.layer.cornerRadius = compHiddenCards.frame.width / 20
        compHiddenCards.layer.borderColor = .init(gray: 0, alpha: 1)
        playerHiddenCards.layer.borderWidth = 1
        playerHiddenCards.layer.cornerRadius = playerHiddenCards.frame.width / 20
        playerHiddenCards.layer.borderColor = .init(gray: 0, alpha: 1)
        upStack.layer.zPosition = 2
        shuffleButton.setTitleColor(.black, for: .normal)
        shuffleButton.layer.borderWidth = 1
        shuffleButton.layer.cornerRadius = shuffleButton.frame.width/40
        midStack.addSubview(tempPlayerCard)
        tempPlayerCard.layer.zPosition = 0
        midStack.addSubview(tempComputerCard)
        tempComputerCard.layer.zPosition = 0
        
    }
    
    func bindViewModel(){
        cancellable = viewModel.deckShuffledPublisher
            .sink(receiveValue: { card in
                DispatchQueue.main.async {
                    self.deckOfCards.image = UIImage(named: "placeholder")
                }
            })
    }
    
    func bindGame() {
        deckEmpty = viewModel.game.$isDeckEmpty
            .sink(receiveValue: { result in
                if result {
                    self.deckOfCards.alpha = 0
                } else {
                    DispatchQueue.main.async {
                        self.deckOfCards.alpha = 1
                    }
                    
                }
            })
        
        playerCards = viewModel.game.player.$cards
            .sink(receiveValue: { cards in
                let n = cards.count
                self.playerLabel.text = "\(n) cards"
                if cards.count > 0 {
                    self.playerHiddenCards.alpha = 1
                } else {
                    self.playerHiddenCards.alpha = 0
                    self.playerLabel.text = ""
                }
            })
        
        computerCards = viewModel.game.computer.$cards
            .sink(receiveValue: { cards in
                let n = cards.count
                self.compLabel.text = "\(n) cards"
                if cards.count > 0 {
                    
                    self.compHiddenCards.alpha = 1
                } else {
                    self.compHiddenCards.alpha = 0
                    self.compLabel.text = ""
                }
            })
        
        playerCardImage = viewModel.game.$currentPlayerCard
            .handleEvents(receiveOutput: { _ in
                DispatchQueue.main.async {
                    self.playerOpenCard.alpha = 1
                }
                
            })
            .assign(to: \.image, on: playerOpenCard)
        
        computerCardImage = viewModel.game.$currentComputerCard
            .handleEvents(receiveOutput: { _ in
                DispatchQueue.main.async {
                    self.compOpenCard.alpha = 1
                }
            })
            .assign(to: \.image, on: compOpenCard)
        
        winStatusCancellable = viewModel.game.whoWon
            .sink(receiveValue: { winStatus in
                switch winStatus {
                case .playerWin:
                    self.cardsFlyAwayAnimation(whoWon: .playerWin) {
                        self.isAnimating = false
                    }
                case .computerWin:
                    self.cardsFlyAwayAnimation(whoWon: .computerWin) {
                        self.isAnimating = false
                    }
                case .noWinner:
                    self.createTempOpenCards()
                    self.isAnimating = false
                }
            })
        
        gameWinnerStatus = viewModel.game.gameWinner
            .sink(receiveValue: { gameWinner in
                switch gameWinner {
                case .playerWin: self.showMessage(text: "Congratulations! You are a winner!")
                case .computerWin: self.showMessage(text: "Oh no, You lose ((")
                default: break
                }
            })
    }
    
    func setupGestureTaps() {
        let deckTap = UITapGestureRecognizer(target: self, action: #selector(tapDeck))
        deckTap.numberOfTapsRequired = 1
        self.deckOfCards.addGestureRecognizer(deckTap)
        
        let playerTap = UITapGestureRecognizer(target: self, action: #selector(playerTap))
        playerTap.numberOfTapsRequired = 1
        self.playerHiddenCards.addGestureRecognizer(playerTap)
        
    }
    
    @IBAction func getCard(_ sender: UIButton) {
        viewModel.shuffleTheCards()
        eraseAll()
    }
    
    @objc func tapDeck() {
        isAnimating ? () : viewModel.deckTapped()
        
    }
    
    @objc func playerTap() {
        isAnimating ? () : viewModel.playerTapped()
        isAnimating ? () : cardsFlyInAnimation(completion: {
            
        })
        isAnimating = true
    }
    
    func eraseAll() {
        playerOpenCard.image = nil
        compOpenCard.image = nil
        playerLabel.text = ""
        compLabel.text = ""
    }
    
    func cardsFlyInAnimation(completion: @escaping ()->()) {
        let translX = playerOpenCard.frame.width + 10
        let translY = playerOpenCard.frame.height + 10
        playerOpenCard.transform = .init(translationX: -translX, y: translY)
        compOpenCard.transform = .init(translationX: 0, y: -translY)
        UIView.animate(withDuration: 0.7) {
//            self.playerOpenCard.transform = .init(translationX: translX, y: translY)
//            self.compOpenCard.transform = .init(translationX: 0, y: -translY)
            self.playerOpenCard.transform = CGAffineTransformIdentity
            self.compOpenCard.transform = CGAffineTransformIdentity
        } completion: { _ in
            completion()
        }
    }
    
    func cardsFlyAwayAnimation(whoWon: TypeBattleWin, completion: @escaping ()->()) {
        tempPlayerCard.image = nil
        tempComputerCard.image = nil
        let translX = playerOpenCard.frame.width + 10
        var translY = playerOpenCard.frame.height + 10
        if whoWon == .computerWin {
            translY = -playerOpenCard.frame.height + 10
        }
        UIView.animate(withDuration: 0.7) {
            self.playerOpenCard.transform = .init(translationX: -translX, y: translY)
            self.compOpenCard.transform = .init(translationX: 0, y: translY)
        } completion: { _ in
            self.playerOpenCard.alpha = 0
            self.compOpenCard.alpha = 0
            self.playerOpenCard.transform = CGAffineTransformIdentity
            self.compOpenCard.transform = CGAffineTransformIdentity
            completion()
        }
    }
    
    func createTempOpenCards() {
        tempPlayerCard.frame = playerOpenCard.frame
        tempComputerCard.frame = compOpenCard.frame
        tempPlayerCard.image = playerOpenCard.image
        tempComputerCard.image = compOpenCard.image
    }
    
    func showMessage(text: String) {
        present(AlertWindow.shared.showAlert(withText: text), animated: true)
    }
}



