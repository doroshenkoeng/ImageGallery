//
//  ImageCollectionViewCell.swift
//  ImageGallery
//
//  Created by Sergey on 13.01.2020.
//  Copyright © 2020 Сергей Дорошенко. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
        
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var label: UILabel!
    var imageURL: URL? {
        didSet {
            updateViewFromModel()
        }
    }
    
    private func updateViewFromModel() {
        activityIndicator.startAnimating()
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if let url = self?.imageURL {
                let data = try? Data(contentsOf: url)
                DispatchQueue.main.async {
                    if let imageData = data, url == self?.imageURL {
                        self?.imageView.image = UIImage(data: imageData)
                    } else {
                        self?.label.isHidden = false
                    }
                    self?.activityIndicator.stopAnimating()
                }
            }
        }
    }
}

