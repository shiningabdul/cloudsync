//
//  ViewController.swift
//  cloudsync
//
//  Created by Abdul Aljebouri on 2019-09-21.
//  Copyright © 2019 shiningdevelopers. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var storedContentLabel: UILabel!
    @IBOutlet weak var storedContentTextField: UITextField!
    
    private let dataManager = DataManager.shared
    private var fetchController: NSFetchedResultsController<Data>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        refresh()
        fetchController = dataManager.fetchControllerForData()
        fetchController?.delegate = self
        
        do {
           try fetchController?.performFetch()
        } catch (let error) {
            print(error)
        }
    }
    
    private func refresh() {
        guard let data = dataManager.getData() else {
            return
        }
        
        storedContentLabel.text = data.text
    }
    
    @IBAction func storeTapped(_ sender: Any) {
        guard let text = storedContentTextField.text else {
            return
        }
        
        dataManager.setData(text: text)
        storedContentLabel.text = text
    }
}

extension ViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("Fetched object results changed")
        
        guard let fetchedObjects = controller.fetchedObjects, fetchedObjects.count > 0 else {
            return
        }
        
        refresh()
    }
}
