//
//  Model.swift
//  CombineURLCardsMvvm
//
//  Created by Maksym Ponomarchuk on 30.01.2023.
//

import UIKit


struct ShuffleTheCards: Codable {
    let success: Bool
    let deck_id: String
    let remaining: Int
    let shuffled: Bool
}


struct CardsJson: Codable {
    let cards: [CardJson]
}


struct CardJson: Codable {
    let image: String
    let value: String
    let suit: String
}


struct Card {
    let value: String
    let suit: String
    let picture: UIImage
}
