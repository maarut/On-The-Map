//
//  MainTabBarViewController.swift
//  On The Map
//
//  Created by Maarut Chandegra on 26/04/2016.
//  Copyright © 2016 Maarut Chandegra. All rights reserved.
//

import UIKit

class MainTabBarViewController: UITabBarController {
    weak var logoutButton: UIBarButtonItem!
    weak var postLocationButton: UIBarButtonItem!
    weak var refreshItemsButton: UIBarButtonItem!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        let logoutButton = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: #selector(logoutTapped(_:)))
        let refreshItemsButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: #selector(refreshTapped(_:)))
        let postLocationButton = UIBarButtonItem(image: UIImage(named: "pin"), style: .Plain, target: self, action: #selector(postLocationTapped(_:)))
        self.logoutButton = logoutButton
        self.refreshItemsButton = refreshItemsButton
        self.postLocationButton = postLocationButton
        navigationItem.setLeftBarButtonItem(logoutButton, animated: false)
        navigationItem.setRightBarButtonItems([refreshItemsButton, postLocationButton], animated: false)
        navigationItem.hidesBackButton = true
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        navigationController?.navigationBarHidden = false
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        navigationController?.navigationBarHidden = true
    }
    
    func refreshTapped(sender: AnyObject)
    {
        if let selectedVC = selectedViewController as? TabBarCommonOperations {
            selectedVC.refreshTapped(sender)
        }
    }
    
    func postLocationTapped(sender: AnyObject)
    {
        print("post")
    }
    
    func logoutTapped(sender: AnyObject)
    {
        logoutButton.enabled = false
        let presentedVC = presentedViewController
        presentedVC?.view.userInteractionEnabled = false
        UdacityClient.sharedInstance().logout { (didSucceed, error) in
            dispatch_async(dispatch_get_main_queue()) {
                self.logoutButton.enabled = true
                presentedVC?.view.userInteractionEnabled = true
                if didSucceed {
                    self.navigationController?.popViewControllerAnimated(true)
                }
                else {
                    let alertController = UIAlertController(title: "Logout Error", message: error?.localizedDescription, preferredStyle: .Alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .Default , handler: { _ in
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }))
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
            }
        }
    }
}