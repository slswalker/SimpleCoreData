//
//  FetchedResultsDataProvider.swift
//  SimpleCoreData
//
//  Created by Sam Walker on 10/12/15.
//  Copyright © 2015 Sam Walker. All rights reserved.
//

import CoreData

class FetchedResultsDataProvider<Delegate: DataProviderDelegate> : NSObject, DataProvider, NSFetchedResultsControllerDelegate {
    
    typealias Object = Delegate.Object
    
    init(fetchedResultsController : NSFetchedResultsController, delegate: Delegate) {
        self.fetchedResultsController = fetchedResultsController
        self.delegate = delegate
        super.init()
    }
    
    // MARK: - DataProvider
    
    func numberOfSections() -> Int {
        if let sections = fetchedResultsController.sections {
            return sections.count
        }
        return 0
    }

    func numberOfItemsInSection(section: Int) -> Int {
        if let section = fetchedResultsController.sections?[section] {
            return section.numberOfObjects
        }
        return 0
    }
    
    func objectAtIndexPath(indexPath: NSIndexPath) -> Object {
        guard let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as? Object
            else { fatalError("Unexpected object at indexPath: \(indexPath)") }
        return object
    }
    
    // MARK: - FetchedResultsControllerDelegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        updates = []
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            guard let indexPath = newIndexPath else { fatalError("Insert index path should not be nil") }
            updates.append(.Insert(indexPath))
        case .Delete:
            guard let indexPath = indexPath else { fatalError("Delete index path should not be nil") }
            updates.append(.Delete(indexPath))
        case .Move:
            guard let indexPath = indexPath else { fatalError("Old index path should not be nil") }
            guard let newIndexPath = newIndexPath else { fatalError("New index path should not be nil") }
            updates.append(.Move(indexPath, newIndexPath))
        case .Update:
            guard let indexPath = indexPath else { fatalError("Update index path should not be nil") }
            let object = objectAtIndexPath(indexPath)
            updates.append(.Update(indexPath, object))
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            delegate?.didUpdateSection(withUpdate: .Insert(sectionIndex))
        case .Delete:
            delegate?.didUpdateSection(withUpdate: .Delete(sectionIndex))
        default: break
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        delegate?.didUpdateObjects(withUpdates: updates)
    }
    
    // MARK: - Private
    
    private let fetchedResultsController: NSFetchedResultsController
    private weak var delegate: Delegate?
    private var updates: [DataRowUpdate<Object>] = []
    
}
