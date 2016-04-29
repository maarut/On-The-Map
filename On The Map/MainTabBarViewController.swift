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

    override func viewDidLoad()
    {
        super.viewDidLoad()
        let logoutButton = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: #selector(logoutTapped(_:)))
        self.logoutButton = logoutButton
        navigationItem.setLeftBarButtonItem(logoutButton, animated: true)
        navigationItem.hidesBackButton = true
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        navigationController?.navigationBarHidden = false
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        navigationController?.navigationBarHidden = true
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
                    let alertController = UIAlertController(title: "Logout Error", message: error?.description, preferredStyle: .Alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .Default , handler: { _ in
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }))
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
            }
        }
    }
}