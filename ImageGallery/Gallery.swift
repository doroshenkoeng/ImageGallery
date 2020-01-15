//
//  Gallery.swift
//  ImageGallery
//
//  Created by Sergey on 13.01.2020.
//  Copyright © 2020 Сергей Дорошенко. All rights reserved.
//

import UIKit

class Gallery {
    var name: String = ""
    var images: [Image] = []
    init(name: String, images: [Image]) {
        self.name = name
        self.images = images
    }
}
