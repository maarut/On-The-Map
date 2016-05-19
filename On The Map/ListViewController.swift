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
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
}

// MARK: - UITableViewDataSource Implementation
extension ListViewController: UITableViewDataSource
{
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if section == 0 {
            return StudentDataStore.studentData.count ?? 0
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("studentData")!
        let studentData = StudentDataStore.studentData[indexPath.row]
        cell.textLabel?.text = "\(studentData.firstName) \(studentData.lastName)"
        cell.imageView?.image = UIImage(named: "pin")
        return cell
    }
}

// MARK: - UITableViewDelegate Implementation
extension ListViewController: UITableViewDelegate
{
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let studentData = StudentDataStore.studentData[indexPath.row]
        if let url = NSURL(string: studentData.mediaURL) {
            if UIApplication.sharedApplication().canOpenURL(url) {
                UIApplication.sharedApplication().openURL(url)
            }
            else {
                let alertController = UIAlertController(title: "Couldn't open URL", message: "The system was not able to open URL - \"\(studentData.mediaURL)\"", preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: { _ in self.dismissViewControllerAnimated(true, completion: nil) }))
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
        else {
            let alertController = UIAlertController(title: "Couldn't open URL", message: "URL \"\(studentData.mediaURL)\" is not a valid URL", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: { _ in self.dismissViewControllerAnimated(true, completion: nil) }))
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

// MARK: - TabBarCommonOperations Implementation
extension ListViewController: TabBarCommonOperations
{
    // Must be called on the main thread
    func refreshTapped(sender: AnyObject)
    {
        tableView.reloadData()
    }
}
