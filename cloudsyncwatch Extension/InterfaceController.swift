//
//  InterfaceController.swift
//  cloudsyncwatch Extension
//
//  Created by Abdul Aljebouri on 2019-09-21.
//  Copyright © 2019 shiningdevelopers. All rights reserved.
//

import WatchKit
import Foundation
import CoreData

class InterfaceController: WKInterfaceController {
    
    @IBOutlet weak var storedContentLabel: WKInterfaceLabel!
    @IBOutlet weak var storedContentTextField: WKInterfaceTextField!
    
    private let dataManager = DataManager.shared
    private var fetchController: NSFetchedResultsController<Data>?
    private var enteredText = ""
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        refresh()
        fetchController = dataManager.fetchControllerForData()
        fetchController?.delegate = self
        
        do {
           try fetchController?.performFetch()
        } catch (let error) {
            print(error)
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    private func refresh() {
        guard let data = dataManager.getData() else {
            return
        }
        
        storedContentLabel.setText(data.text)
    }

    @IBAction func textEntered(_ value: NSString?) {
        guard let text = value else {
            return
        }
        
        enteredText = String(text)
    }
    
    @IBAction func setTapped() {
        dataManager.setData(text: enteredText)
        storedContentLabel.setText(enteredText)
    }
}

extension InterfaceController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("Fetched object results changed")
        
        guard let fetchedObjects = controller.fetchedObjects, fetchedObjects.count > 0 else {
            return
        }
        
        refresh()
    }
}
