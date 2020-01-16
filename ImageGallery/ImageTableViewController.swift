//
//  ImageTableViewController.swift
//  ImageGallery
//
//  Created by Sergey on 14.01.2020.
//  Copyright © 2020 Сергей Дорошенко. All rights reserved.
//

import UIKit

class ImageTableViewController: UITableViewController {

    private var galleries = [[Gallery]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        galleries = [
            [
                Gallery(name: "Gallery 1", images: []), Gallery(name: "Gallery 2", images: []), Gallery(name: "Gallery 3", images: [])
            ],
            [
                Gallery(name: "Gallery 4", images: [])
            ]
        ]
        let image1 = Image(url: URL(string: "https://i.pinimg.com/originals/fc/ae/4b/fcae4bb94c4c2a7aba55138c7fac8e5a.jpg")!, aspectRatio: 836 / 1044)
        let image2 = Image(url: URL(string: "https://www.topdeck.travel/sites/default/files/styles/hero_image_mobile/public/2018-09/HERO%201920x540-Europe-Spain.jpg?itok=hEc5cdOB")!, aspectRatio: 75 / 54)
        galleries[0][0].images += [image1, image2]
    }
    
    private var lastSelectedRow = IndexPath(row: 0, section: 0)
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        lastSelectedRow = indexPath
        performSegue(withIdentifier: "Show Gallery", sender: indexPath)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        selectRow(at: lastSelectedRow)
    }
    
    @IBAction func touchAddButton(_ sender: UIBarButtonItem) {
        galleries[0] += [Gallery(name: "Untitled".madeUnique(withRespectTo: galleries[0].map { $0.name }), images: [])]
        tableView.insertRows(at: [IndexPath(row: galleries[0].count - 1, section: 0)], with: .automatic)
        selectRow(at: IndexPath(row: 0, section: 0))
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return galleries.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return galleries[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()

        switch indexPath.section {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "ImageTableViewCell", for: indexPath)
            if let galleryCell = cell as? ImageTableViewCell {
                galleryCell.textField.text = galleries[indexPath.section][indexPath.row].name
                galleryCell.resignationHandler = { [weak self, unowned galleryCell] in
                    if let name = galleryCell.textField.text {
                        self?.galleries[indexPath.section][indexPath.row].name = name
                        self?.tableView.reloadData()
                        self?.selectRow(at: indexPath)
                    }
                    
                }
            }
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "TitleTableViewCell", for: indexPath)
            cell.textLabel?.text = galleries[indexPath.section][indexPath.row].name
        default: break
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 1 && galleries[1].count > 0 ? "Recentrly Deleted" : nil
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            switch indexPath.section {
            case 0:
                tableView.performBatchUpdates({
                    galleries[1].insert(galleries[0].remove(at: indexPath.row), at: 0)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    tableView.insertRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
                }) { _ in
                    self.selectRow(at: IndexPath(row: 0, section: 1), with: Constants.duration)
                }
                
            case 1:
                tableView.performBatchUpdates({
                    galleries[1].remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }) { _ in
                    self.selectRow(at: IndexPath(row: 0, section: 0), with: Constants.duration)
                    if self.galleries[1].count == 0 { tableView.reloadSections(IndexSet(integer: 1), with: .automatic)}
                }
                
            default: break
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    private func selectRow(at indexPath: IndexPath, with delay: TimeInterval = 0) {
        Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { (timer) in
            self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard indexPath.section == 1 else { return nil }
        let contextualActions = UIContextualAction(style: .normal, title: "Undelete") { (action, view, nil) in
            tableView.performBatchUpdates({
                self.galleries[0].insert(self.galleries[1].remove(at: indexPath.row), at: 0)
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            }) { _ in
                self.selectRow(at: IndexPath(row: 0, section: 0), with: Constants.duration)
            }
        }
        return UISwipeActionsConfiguration(actions: [contextualActions])
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if splitViewController?.preferredDisplayMode != .primaryOverlay {
            splitViewController?.preferredDisplayMode = .primaryOverlay
        }
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        switch segue.identifier {
//        case "Show Gallery":
//            if let cell = sender as? ImageTableViewCell, let cvc = segue.destination.contents as? ImageCollectionViewController, let indexPath = tableView.indexPath(for: cell) {
//                cvc.gallery = galleries[indexPath.section][indexPath.row]
//                cvc.title = galleries[indexPath.section][indexPath.row].name
//                cvc.collectionView.isUserInteractionEnabled = true
//            }
//        case "Show Recently Deleted Gallery":
//            if let cell = sender as? UITableViewCell, let cvc = segue.destination.contents as? ImageCollectionViewController, let indexPath = tableView.indexPath(for: cell) {
//                cvc.gallery = galleries[indexPath.section][indexPath.row]
//                cvc.title = "Recently Deleted " + galleries[indexPath.section][indexPath.row].name
//                cvc.collectionView.isUserInteractionEnabled = false
//                cvc.collectionView.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
//            }
//        default: break
//        }
        guard segue.identifier == "Show Gallery", let indexPath = sender as? IndexPath else { return }
        switch indexPath.section {
        case 0:
            if let cvc = segue.destination.contents as? ImageCollectionViewController {
                cvc.gallery = galleries[indexPath.section][indexPath.row]
                cvc.title = galleries[indexPath.section][indexPath.row].name
                cvc.collectionView.isUserInteractionEnabled = true
            }
        case 1:
            if let cvc = segue.destination.contents as? ImageCollectionViewController {
                cvc.gallery = galleries[indexPath.section][indexPath.row]
                cvc.title = "Recently Deleted " + galleries[indexPath.section][indexPath.row].name
                cvc.collectionView.isUserInteractionEnabled = false
                cvc.collectionView.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            }
        default: break
        }
    }
    

}
