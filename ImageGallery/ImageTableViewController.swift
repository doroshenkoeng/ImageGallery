//
//  ImageTableViewController.swift
//  ImageGallery
//
//  Created by Sergey on 14.01.2020.
//  Copyright © 2020 Сергей Дорошенко. All rights reserved.
//

import UIKit

class ImageTableViewController: UITableViewController {

    private var galleries = [[Gallery(name: "Gallery 1", images: [])]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate?.tableView?(tableView, didSelectRowAt: lastSelectedRow)
    }
    
    private var collectionViewController: ImageCollectionViewController? {
        let navcon = splitViewController?.viewControllers.last as? UINavigationController
        print("collectionViewController property: \(navcon?.viewControllers.count ?? -1)")
        return navcon?.viewControllers.first as? ImageCollectionViewController
    }
    
    private func showCollection(at indexPath: IndexPath) {
        guard let cvc = collectionViewController else { return }
        lastSelectedRow = indexPath
        switch indexPath.section {
        case 0:
            cvc.gallery = galleries[indexPath.section][indexPath.row]
            cvc.title = galleries[indexPath.section][indexPath.row].name
            cvc.collectionView.isUserInteractionEnabled = true
        case 1:
            cvc.gallery = galleries[indexPath.section][indexPath.row]
            cvc.title = "Recently Deleted " + galleries[indexPath.section][indexPath.row].name
            cvc.collectionView.isUserInteractionEnabled = false
            cvc.collectionView.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        default: break
        }
    }
    
    private var lastSelectedRow = IndexPath(row: 0, section: 0)
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showCollection(at: indexPath)
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
                if galleries.count < 2 {
                    galleries += [[galleries[0].remove(at: indexPath.row)]]
                    tableView.reloadData()
                } else {
                    tableView.performBatchUpdates({
                        galleries[1].insert(galleries[0].remove(at: indexPath.row), at: 0)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                        tableView.insertRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
                    }) { _ in
                        self.selectRow(at: IndexPath(row: 0, section: 1), with: Constants.duration)
                    }
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

}
