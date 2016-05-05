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
        if let sl = (UIApplication.sharedApplication().delegate as? AppDelegate)?.studentLocations {
            studentLocations = sl
            tableView.reloadData()
        }
        else {
            ParseClient.sharedInstance().getStudentLocations { (studentLocations, error) in
                dispatch_async(dispatch_get_main_queue()) {
                    guard error == nil else {
                        let alertController = UIAlertController(title: "Couldn't fetch data", message: "\(error!.localizedDescription)", preferredStyle: .Alert)
                        alertController.addAction(UIAlertAction(title: "Okay", style: .Default, handler: { _ in self.dismissViewControllerAnimated(true, completion: nil) }))
                        self.presentViewController(alertController, animated: true, completion: nil)
                        return
                    }
                    if let studentLocations = studentLocations {
                        (UIApplication.sharedApplication().delegate as? AppDelegate)?.studentLocations = studentLocations
                        self.studentLocations = studentLocations
                        self.tableView.reloadData()
                    }
                }
            }
        }
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
            cell.imageView?.image = UIImage(named: "pin")
        }
        return cell
    }
}

extension ListViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if let studentLocation = studentLocations?[indexPath.row] {
            if let url = NSURL(string: studentLocation.mediaURL) {
                if UIApplication.sharedApplication().canOpenURL(url) {
                    UIApplication.sharedApplication().openURL(url)
                }
                else {
                    let alertController = UIAlertController(title: "Couldn't open URL", message: "The system was not able to open URL - \"\(studentLocation.mediaURL)\"", preferredStyle: .Alert)
                    alertController.addAction(UIAlertAction(title: "Okay", style: .Default, handler: { _ in self.dismissViewControllerAnimated(true, completion: nil) }))
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
            }
            else {
                let alertController = UIAlertController(title: "Couldn't open URL", message: "URL \"\(studentLocation.mediaURL)\" is not a valid URL", preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: "Okay", style: .Default, handler: { _ in self.dismissViewControllerAnimated(true, completion: nil) }))
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }
}

extension ListViewController: TabBarCommonOperations {
    // Must be called on the main thread
    func refreshTapped(sender: AnyObject)
    {
        studentLocations = (UIApplication.sharedApplication().delegate as? AppDelegate)?.studentLocations
        self.tableView.reloadData()
    }
}
