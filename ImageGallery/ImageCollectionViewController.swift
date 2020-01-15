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

    var gallery = Gallery(name: "", images: []) {
        didSet {
            if !(gallery === oldValue) { collectionView.reloadData() }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        images += [
//            Image(url: URL(string: "https://images.unsplash.com/photo-1530122037265-a5f1f91d3b99?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80")!, aspectRatio: 1),
//            Image(url: URL(string: "https://media.radissonhotels.net/image/Destination-Pages/Localattraction/16256-118729-f63223794_3XL.jpg?impolicy=HomeHero")!, aspectRatio: 1),
//            Image(url: URL(string: "https://i.pinimg.com/originals/8c/15/4f/8c154f27ad90c19108c3391a4a677189.jpg")!, aspectRatio: 1),
//            Image(url: URL(string: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSk_PQEF7InJEHewSWPqH7CjNWBYQOhcyotKm4RowcnwmybeE5C&s")!, aspectRatio: 1),
//            Image(url: URL(string: "https://www.luxurygold.com/-/media/luxury-gold/trips/2019-2020/worldwide/europe-and-britain-definite-departures/majesticswitzerland_g160_definitedepartures_hero01.jpg?h=660&w=1920&la=en&hash=FA9C139A377F8FA087D978C7D12FEC92E849FFB7")!, aspectRatio: 1)
//        ]
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinch(_:)))
        collectionView.addGestureRecognizer(pinch)
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem

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
            imageVC.imageURL = gallery.images[indexPath.item].url
        }
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gallery.images.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)

        if let imageCell = cell as? ImageCollectionViewCell {
            imageCell.imageURL = gallery.images[indexPath.item].url
        }
        
        return cell
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        flowLayout?.invalidateLayout()
    }

}

extension ImageCollectionViewController: UICollectionViewDelegateFlowLayout {
    private var flowLayout: UICollectionViewFlowLayout? {
        collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: width, height: width / gallery.images[indexPath.item].aspectRatio)
    }
    
    private var width: CGFloat {
        let boundsWidth = collectionView.bounds.width
        let gapsWidth = (flowLayout?.minimumInteritemSpacing)! * (Constants.numberOfItemsInRow - 1)
        let borderGapsWidth = (flowLayout?.sectionInset.left)! + (flowLayout?.sectionInset.right)!
        let width = (boundsWidth - gapsWidth - borderGapsWidth) / Constants.numberOfItemsInRow * scale
        return min(max(width, Constants.minWidthRatio * boundsWidth), boundsWidth)
    }
}

extension ImageCollectionViewController: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        session.localContext = collectionView
        return dragItems(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        dragItems(at: indexPath)
    }
    
    private func dragItems(at indexPath: IndexPath) -> [UIDragItem] {
        if let imageCell = collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell,
            let image = imageCell.imageView.image {
            let dragItem = UIDragItem(itemProvider: NSItemProvider(object: image))
            dragItem.localObject = gallery.images[indexPath.item]
            return [dragItem]
        } else {
            return []
        }
    }
    
}

extension ImageCollectionViewController: UICollectionViewDropDelegate {
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        let isSelf = (session.localDragSession?.localContext as? UICollectionView) == collectionView
        return isSelf ? session.canLoadObjects(ofClass: UIImage.self) : session.canLoadObjects(ofClass: UIImage.self) && session.canLoadObjects(ofClass: NSURL.self)
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        let isSelf = (session.localDragSession?.localContext as? UICollectionView) == collectionView
        return UICollectionViewDropProposal(operation: isSelf ? .move : .copy, intent: .insertAtDestinationIndexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        for item in coordinator.items {
            if let sourceIndexPath = item.sourceIndexPath {
                if let image = item.dragItem.localObject as? Image {
                    collectionView.performBatchUpdates({
                        gallery.images.remove(at: sourceIndexPath.item)
                        gallery.images.insert(image, at: destinationIndexPath.item)
                        collectionView.moveItem(at: sourceIndexPath, to: destinationIndexPath)
                    })
                    coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
                }
            }
            // not a local case
            else {
                var aspectRatio: CGFloat = 1
                item.dragItem.itemProvider.loadObject(ofClass: UIImage.self) { (provider, error) in
                    DispatchQueue.main.async {
                        if let image = provider as? UIImage {
                            aspectRatio = image.size.width / image.size.height
                        }
                    }
                }
                
                let placeholderContext = coordinator.drop(item.dragItem, to: .init(insertionIndexPath: destinationIndexPath, reuseIdentifier: "DropPlaceholderCell"))
                item.dragItem.itemProvider.loadObject(ofClass: NSURL.self) { (provider, error) in
                    DispatchQueue.main.async {
                        if let url = provider as? URL {
                            placeholderContext.commitInsertion { (insertionIndexPath) in
                                self.gallery.images.insert(Image(url: url.imageURL, aspectRatio: aspectRatio), at: insertionIndexPath.item)
                            }
                        } else {
                            placeholderContext.deletePlaceholder()
                        }
                    }
                }
            }
        }
    }
    
    
}
