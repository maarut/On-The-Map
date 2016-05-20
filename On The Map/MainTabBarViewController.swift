//
//  MainTabBarViewController.swift
//  On The Map
//
//  Created by Maarut Chandegra on 26/04/2016.
//  Copyright © 2016 Maarut Chandegra. All rights reserved.
//

import UIKit

class MainTabBarViewController: UITabBarController
{
    // MARK: - Instance Variables
    weak var logoutButton: UIBarButtonItem!
    weak var postLocationButton: UIBarButtonItem!
    weak var refreshItemsButton: UIBarButtonItem!

    // MARK: - Overrides
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
        StudentDataStore.refreshStudentDataWithCompletionHandler { (didSucceed, error) in
            if !didSucceed {
                NSLog(error!.description + "\n" + error!.localizedDescription)
                return
            }
            if let selectedVC = self.selectedViewController as? TabBarCommonOperations {
                onMainQueueDo { selectedVC.refreshTapped(self) }
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        navigationController?.navigationBarHidden = true
    }
    
    // MARK: - Public Functions
    func refreshTapped(sender: AnyObject)
    {
        refreshItemsButton.enabled = false
        StudentDataStore.refreshStudentDataWithCompletionHandler { (didSucceed, error) in
            onMainQueueDo {
                self.refreshItemsButton.enabled = true
                guard didSucceed else {
                    self.showErrorWithTitle("Data Fetch Error", error: error!)
                    return
                }
                if let selectedVC = self.selectedViewController as? TabBarCommonOperations {
                    selectedVC.refreshTapped(sender)
                }
            }
        }
    }
    
    func postLocationTapped(sender: UIBarButtonItem)
    {
        let displayPostLocationVCOverridingExistingPostOnSubmit = { (shouldOverwrite: Bool?) in
            let nextVC = self.storyboard!.instantiateViewControllerWithIdentifier("postLinkViewController") as! PostLinkViewController
            nextVC.shouldOverwritePreviousPost = shouldOverwrite
            self.presentViewController(nextVC, animated: true, completion: nil)
        }
        switch StudentDataStore.currentlyLoggedInUsersPreviousPost {
        case .Undetermined:
            NSLog("Cannot determine if the currently logged in user has previously posted. A further check will be made before submitting the post.")
            displayPostLocationVCOverridingExistingPostOnSubmit(nil)
            break
        case .NeverPosted:
            displayPostLocationVCOverridingExistingPostOnSubmit(false)
            break
        case .HasPosted:
            let alertController = UIAlertController(title: "Overwrite Previous Location?", message: "You have previously posted a location at which you're studying. Would you like to update that post, or would you like to post a new location?", preferredStyle: .Alert)
            let overwriteButton = UIAlertAction(title: "Overwrite", style: .Default, handler: { _ in displayPostLocationVCOverridingExistingPostOnSubmit(true) })
            let newButton = UIAlertAction(title: "New", style: .Default, handler: { _ in displayPostLocationVCOverridingExistingPostOnSubmit(false) })
            alertController.addAction(overwriteButton)
            alertController.addAction(newButton)
            self.presentViewController(alertController, animated: true, completion: nil)
            break
        }
    }
    
    func logoutTapped(sender: AnyObject)
    {
        logoutButton.enabled = false
        let presentedVC = presentedViewController
        presentedVC?.view.userInteractionEnabled = false
        UdacityClient.sharedInstance().logout { (didSucceed, error) in
            onMainQueueDo {
                self.logoutButton.enabled = true
                presentedVC?.view.userInteractionEnabled = true
                if didSucceed {
                    self.navigationController?.popViewControllerAnimated(true)
                }
                else {
                    self.showErrorWithTitle("Logout Error", error: error!)
                }
            }
        }
    }
    
    // MARK: - Private Functions
    private func showErrorWithTitle(title: String, error: NSError)
    {
        let alertController = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .Default , handler: { _ in }))
        presentViewController(alertController, animated: true, completion: nil)
        NSLog(error.description + "\n" + error.localizedDescription)
    }
}