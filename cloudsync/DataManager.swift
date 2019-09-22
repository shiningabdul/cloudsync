//
//  DataManager.swift
//  h2o
//
//  Created by Abdul Aljebouri on 2018-08-18.
//  Copyright © 2018 shiningdevelopers. All rights reserved.
//

import Foundation
import CoreData

class DataManager : NSObject {
    static let shared = DataManager()

    #if os(watchOS)
    let transactionAuthorName = "watchOSApp"
    #else
    let transactionAuthorName = "iOSApp"
    #endif
    
    override private init() {
        super.init()
    }
    
    func getData() -> Data? {
        let fetchRequest: NSFetchRequest<Data> = Data.fetchRequest()
        
        var fetchedObjects: [Data]? = nil
        do {
            fetchedObjects = try managedObjectContext().fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        guard let dateEntries = fetchedObjects, dateEntries.count > 0 else {
            return nil
        }
        
        return dateEntries[0]
    }
    
    func setData(text: String) {
        var data = getData()

        if let data = data {
            data.text = text
            data.lastModified = Date()
        } else {
            data = Data(context: managedObjectContext())
            data?.text = text
            data?.lastModified = Date()
        }

        saveContext()
    }

    func fetchControllerForData() -> NSFetchedResultsController<Data> {
        let fetchRequest: NSFetchRequest<Data> = Data.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastModified", ascending: false)]
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext(), sectionNameKeyPath: nil, cacheName: nil)
        return controller
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentCloudKitContainer(name: "cloudsync")
        
        let cloudStoreUrl = applicationDocumentDirectory()!.appendingPathComponent("h20.sqlite")
        
        let cloudStoreDescription = NSPersistentStoreDescription(url: cloudStoreUrl)
        
        cloudStoreDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        cloudStoreDescription.shouldInferMappingModelAutomatically = true
        cloudStoreDescription.shouldMigrateStoreAutomatically = true
        cloudStoreDescription.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier:"iCloud.com.shiningdevelopers.cloudsync")
            
        container.persistentStoreDescriptions = [cloudStoreDescription]
        
        container.loadPersistentStores(completionHandler: { storeDescription, error in
            if let error = error as NSError? {
                print("Error: \(error)")
            }
        })
        
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        try? container.viewContext.setQueryGenerationFrom(.current)
        container.viewContext.transactionAuthor = transactionAuthorName
        
        return container
    }()
}

// MARK: - Core Data
extension DataManager {
    
    func applicationDocumentDirectory() -> URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    func managedObjectContext() -> NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func reset() {
        managedObjectContext().reset()
    }
    
    func saveContext () {
        let context = managedObjectContext()
        if context.hasChanges {
            do {
                try context.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
}
