//
//  ListViewController.swift
//  On The Map
//
//  Created by Maarut Chandegra on 03/05/2016.
//  Copyright © 2016 Maarut Chandegra. All rights reserved.
//

import UIKit

class ListViewController: UIViewController
{
    @IBOutlet weak var tableView: UITableView!
    var studentLocations: [StudentLocation]?
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
    }

}

extension ListViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if section == 0 {
            return studentLocations?.count ?? 0
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("studentLocation")!
        if let studentLocation = studentLocations?[indexPath.row] {
            cell.textLabel?.text = "\(studentLocation.firstName) \(studentLocation.lastName)"
        }
        return cell
    }
}

extension ListViewController: UITableViewDelegate {
    
}

extension ListViewController: TabBarCommonOperations {
    // Must be called on the main thread
    func refreshTapped(sender: AnyObject)
    {
        studentLocations = (UIApplication.sharedApplication().delegate as? AppDelegate)?.studentLocations
        self.tableView.reloadData()
    }
}
