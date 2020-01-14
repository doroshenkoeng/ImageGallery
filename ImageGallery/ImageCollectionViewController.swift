//
//  ImageCollectionViewController.swift
//  ImageGallery
//
//  Created by Sergey on 13.01.2020.
//  Copyright © 2020 Сергей Дорошенко. All rights reserved.
//

import UIKit

private let reuseIdentifier = "ImageCollectionViewCell"

class ImageCollectionViewController: UICollectionViewController {

    private var images = [Image]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        images += [
            Image(url: URL(string: "https://images.unsplash.com/photo-1530122037265-a5f1f91d3b99?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80")!, aspectRatio: 1),
            Image(url: URL(string: "https://media.radissonhotels.net/image/Destination-Pages/Localattraction/16256-118729-f63223794_3XL.jpg?impolicy=HomeHero")!, aspectRatio: 1),
            Image(url: URL(string: "https://i.pinimg.com/originals/8c/15/4f/8c154f27ad90c19108c3391a4a677189.jpg")!, aspectRatio: 1),
            Image(url: URL(string: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSk_PQEF7InJEHewSWPqH7CjNWBYQOhcyotKm4RowcnwmybeE5C&s")!, aspectRatio: 1),
            Image(url: URL(string: "https://www.luxurygold.com/-/media/luxury-gold/trips/2019-2020/worldwide/europe-and-britain-definite-departures/majesticswitzerland_g160_definitedepartures_hero01.jpg?h=660&w=1920&la=en&hash=FA9C139A377F8FA087D978C7D12FEC92E849FFB7")!, aspectRatio: 1)
        ]
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinch(_:)))
        collectionView.addGestureRecognizer(pinch)
    }
    
    @objc private func pinch(_ recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .changed:
            scale *= recognizer.scale
            recognizer.scale = 1.0
        default: break
        }
    }
    
    private var scale: CGFloat = 1 {
        didSet {
            flowLayout?.invalidateLayout()
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let imageVC = segue.destination.contents as? ImageViewController,
            let imageCell = sender as? ImageCollectionViewCell,
            let indexPath = collectionView.indexPath(for: imageCell),
            segue.identifier == "Show Image" {
            imageVC.imageURL = images[indexPath.item].url
        }
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)

        if let imageCell = cell as? ImageCollectionViewCell {
            imageCell.imageURL = images[indexPath.item].url
        }
        
        return cell
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        flowLayout?.invalidateLayout()
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}

extension ImageCollectionViewController: UICollectionViewDelegateFlowLayout {
    private var flowLayout: UICollectionViewFlowLayout? {
        collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: width, height: width / images[indexPath.item].aspectRatio)
    }
    
    private var width: CGFloat {
        let boundsWidth = collectionView.bounds.width
        let gapsWidth = (flowLayout?.minimumInteritemSpacing)! * (Constants.numberOfItemsInRow - 1)
        let borderGapsWidth = (flowLayout?.sectionInset.left)! + (flowLayout?.sectionInset.right)!
        let width = (boundsWidth - gapsWidth - borderGapsWidth) / Constants.numberOfItemsInRow * scale
        return min(max(width, Constants.minWidthRatio * boundsWidth), boundsWidth)
    }
}

