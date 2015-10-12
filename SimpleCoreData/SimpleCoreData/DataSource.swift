//
//  DataSource.swift
//  SimpleCoreData
//
//  Created by Sam Walker on 10/12/15.
//  Copyright © 2015 Sam Walker. All rights reserved.
//

protocol DataSourceDelegate : class {
    typealias Object
    func cellIdentifierForIndexPath(indexPath: NSIndexPath) -> String
}

protocol TableViewDataSourceDelegate : DataSourceDelegate {
    func configureCell(cell: UITableViewCell, withObject object: Object, atIndexPath indexPath: NSIndexPath)
}
