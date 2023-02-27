//
//  AlertWindow.swift
//  CombineURLCardsMvvm
//
//  Created by Maksym Ponomarchuk on 03.02.2023.
//

import UIKit

class AlertWindow {
    static var shared = AlertWindow()
    func showAlert (withText: String) -> UIAlertController {
        let controller = UIAlertController(title: nil, message: withText, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .cancel)
        controller.addAction(action)
        return controller
    }
}
