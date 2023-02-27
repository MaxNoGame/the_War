//
//  NetworkLayer.swift
//  CombineURLCardsMvvm
//
//  Created by Maksym Ponomarchuk on 30.01.2023.
//

import UIKit
import Combine

class NetworkLayer {
    
    func fetchCard(url: URL, completion: @escaping ([CardJson])->()) {
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                print("ERROR URL for fetchn cards")
            }
            if let data = data {
                self.jsonDecode(data: data) { card in
                    completion(card.cards)
                }
            }
        }.resume()
        
    }
    
    private func jsonDecode(data: Data, completion: (CardsJson)->()){
        let decoder = JSONDecoder()
        if let clearData = try? decoder.decode(CardsJson.self, from: data){
            //print(clearData.cards.first?.value)
            completion(clearData)
        }
        
    }
    func getPicture(stringUrl: String, completion: @escaping (UIImage?)->()) {
//        completion(nil)
//        return
        guard let url = URL(string: stringUrl) else {return}
        DispatchQueue.global(qos:.background).async{
            if let data = try? Data(contentsOf: url){
                DispatchQueue.main.async {
                    if let image = UIImage(data: data) {
                        completion(image)
                    }
                }
                
            }
           completion(nil)
        }
    }
    
    func getNewDeck(url: URL, completion: @escaping (ShuffleTheCards?)->()) {
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                print("ERROR URL for fetchn cards")
            }
            if let data = data {
                let decoder = JSONDecoder()
                if let clearData = try? decoder.decode(ShuffleTheCards.self, from: data){
                    completion(clearData)
                }
            }
        }.resume()
    }
}
