//
//  TableViewDataSource.swift
//  SimpleCoreData
//
//  Created by Sam Walker on 10/12/15.
//  Copyright © 2015 Sam Walker. All rights reserved.
//

import UIKit

class TableViewDataSource<Delegate: TableViewDataSourceDelegate, Data: DataProvider where Delegate.Object == Data.Object> : NSObject, UITableViewDataSource, DataProviderDelegate {
    
    private weak var tableView: UITableView?
    private weak var delegate: Delegate!
    private var dataProvider: Data
    
    required init(tableView: UITableView, dataProvider: Data, delegate: Delegate) {
        self.tableView = tableView
        self.dataProvider = dataProvider
        self.delegate = delegate
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return dataProvider.numberOfSections()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataProvider.numberOfItemsInSection(section)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = delegate.cellIdentifierForIndexPath(indexPath)
        let object = dataProvider.objectAtIndexPath(indexPath)
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath)
        delegate.configureCell(cell, withObject: object, atIndexPath: indexPath)
        return cell
    }
    
    // MARK: - DataProviderDelegate
    
    func didUpdateObjects(withUpdates updates: [DataRowUpdate<Data.Object>]) {
        tableView?.beginUpdates()
        for update in updates {
            switch update {
            case .Insert(let indexPath):
                tableView?.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            case .Delete(let indexPath):
                tableView?.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            case .Update(let indexPath, let object):
                let cell = tableView?.cellForRowAtIndexPath(indexPath)
                delegate.configureCell(cell, withObject: object, atIndexPath: indexPath)
            case .Move(let oldIndexPath, let newIndexPath):
                tableView?.moveRowAtIndexPath(oldIndexPath, toIndexPath: newIndexPath)
            }
        }
        tableView?.endUpdates()
    }
    
    func didUpdateSection(withUpdate update: DataSectionUpdate) {
        tableView?.beginUpdates()
        switch update {
        case .Insert(let index):
            tableView?.insertSections(NSIndexSet(index: index), withRowAnimation: .Automatic)
        case .Delete(let index):
            tableView?.deleteSections(NSIndexSet(index: index), withRowAnimation: .Automatic)
        }
    }
}
