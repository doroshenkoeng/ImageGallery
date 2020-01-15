//
//  ImageTableViewCell.swift
//  ImageGallery
//
//  Created by Sergey on 14.01.2020.
//  Copyright © 2020 Сергей Дорошенко. All rights reserved.
//

import UIKit

class ImageTableViewCell: UITableViewCell {

    @IBOutlet weak var textField: UITextField! {
        didSet {
            textField.delegate = self
            let tap = UITapGestureRecognizer(target: self, action: #selector(tap(recognizer:)))
            tap.numberOfTapsRequired = 2
            addGestureRecognizer(tap)
        }
    }
    
    var resignationHandler: (() -> Void)?
    
    @objc private func tap(recognizer: UITapGestureRecognizer) {
        textField.isEnabled = true
        textField.becomeFirstResponder()
    }
    
}

extension ImageTableViewCell: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        resignationHandler?()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.isEnabled = false
        textField.resignFirstResponder()
        return true
    }
}
