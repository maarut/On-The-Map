//
//  PostLinkViewController.swift
//  On The Map
//
//  Created by Maarut Chandegra on 13/05/2016.
//  Copyright © 2016 Maarut Chandegra. All rights reserved.
//

import UIKit
import MapKit

class PostLinkViewController: UIViewController
{
    // MARK: - IBOutlets
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var findOnTheMapButton: UIButton!
    @IBOutlet weak var useCurrentLocationButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var locationEntryField: UITextView!
    @IBOutlet weak var urlEntry: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var shouldOverwritePreviousPost = true
    
    // MARK: - Overrides
    override func viewDidLoad()
    {
        super.viewDidLoad()
        for button in [useCurrentLocationButton, findOnTheMapButton, submitButton] {
            button.layer.cornerRadius = 5.0
        }
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        view.backgroundColor = UIColor(hexValue: 0xEFEFF4)
        [titleLabel, locationEntryField, findOnTheMapButton, useCurrentLocationButton].forEach {
            $0.hidden = false
            $0.alpha = 1.0
        }
        [mapView, urlEntry, submitButton].forEach {
            $0.hidden = true
            $0.alpha = 0.0
        }
        [urlEntry, submitButton].forEach { $0.enabled = false }
        [findOnTheMapButton, useCurrentLocationButton].forEach { $0.enabled = true }
        cancelButton.setTitleColor(nil, forState: .Normal)
    }
    
    // MARK: - IBActions
    @IBAction func findLocationTapped(sender: AnyObject)
    {
        guard locationEntryField.text != nil && !locationEntryField.text!.isEmpty else {
            let alert = UIAlertController(title: "Location Not Provided", message: "A location has not been provided. Please either enter a location, or request to use the current location.", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Enter Location", style: .Default, handler: nil))
            alert.addAction(UIAlertAction(title: "Use Current Location", style: .Default, handler: { _ in self.useCurrentLocationTapped(self) }))
            presentViewController(alert, animated: true, completion: nil)
            return
        }
        [mapView, urlEntry, submitButton].forEach { $0.hidden = false }
        UIView.animateWithDuration(0.5, animations: {
            self.view.backgroundColor = UIColor(hexValue: 0x3B5998)
            self.cancelButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            [self.titleLabel, self.locationEntryField, self.findOnTheMapButton, self.useCurrentLocationButton].forEach {
                $0.alpha = 0.0
            }
            [self.mapView, self.urlEntry, self.submitButton].forEach { $0.alpha = 1.0 }
            [self.urlEntry, self.submitButton].forEach { $0.enabled = true }
            [self.findOnTheMapButton, self.useCurrentLocationButton].forEach { $0.enabled = false }
            }, completion: { didFinish in
                [self.titleLabel, self.locationEntryField, self.findOnTheMapButton, self.useCurrentLocationButton].forEach {
                    $0.hidden = true
                }
        })
    }
    
    @IBAction func submitTapped(sender: AnyObject)
    {
        
    }
    
    @IBAction func useCurrentLocationTapped(sender: AnyObject)
    {
        
    }
    
    @IBAction func cancelTapped(sender: AnyObject)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func tapRecognised(sender: UITapGestureRecognizer)
    {
        let tapLocation = locationEntryField.convertPoint(sender.locationInView(self.view), fromView: self.view)
        
        if !locationEntryField.pointInside(tapLocation, withEvent: nil) {
            locationEntryField.resignFirstResponder()
        }
    }
}

// MARK: - UITextViewDelegate Implementation
extension PostLinkViewController: UITextViewDelegate
{
    func textViewShouldBeginEditing(textView: UITextView) -> Bool
    {
        textView.text = ""
        textView.textColor = UIColor.whiteColor()
        return true
    }
}
