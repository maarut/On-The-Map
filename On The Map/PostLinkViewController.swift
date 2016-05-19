//
//  PostLinkViewController.swift
//  On The Map
//
//  Created by Maarut Chandegra on 13/05/2016.
//  Copyright © 2016 Maarut Chandegra. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

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
    private var textFieldPlaceHolderText = "Enter Location Here"
    private var canUseCurrentLocationButton = true
    private var locationManager = CLLocationManager()
    
    // MARK: - Overrides
    override func viewDidLoad()
    {
        super.viewDidLoad()
        for button in [useCurrentLocationButton, findOnTheMapButton, submitButton] {
            button.layer.cornerRadius = 5.0
        }
        switch CLLocationManager.authorizationStatus() {
        case .AuthorizedAlways, .AuthorizedWhenInUse:
            canUseCurrentLocationButton = true
            useCurrentLocationButton.hidden = false
            useCurrentLocationButton.enabled = true
            break
        default:
            canUseCurrentLocationButton = false
            useCurrentLocationButton.hidden = true
            useCurrentLocationButton.enabled = false
            break
        }
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        view.backgroundColor = UIColor(hexValue: 0xEFEFF4)
        [titleLabel, locationEntryField, findOnTheMapButton].forEach {
            $0.hidden = false
            $0.alpha = 1.0
        }
        [mapView, urlEntry, submitButton].forEach {
            $0.hidden = true
            $0.alpha = 0.0
        }
        [urlEntry, submitButton].forEach { $0.enabled = false }
        findOnTheMapButton.enabled = true
        if canUseCurrentLocationButton {
            useCurrentLocationButton.hidden = false
            useCurrentLocationButton.enabled = true
            useCurrentLocationButton.alpha = 1.0
        }
        cancelButton.setTitleColor(nil, forState: .Normal)
    }
    
    // MARK: - IBActions
    @IBAction func findLocationTapped(sender: AnyObject)
    {
        guard locationEntryField.text != nil && !locationEntryField.text!.isEmpty && locationEntryField.text != textFieldPlaceHolderText else {
            let alert = UIAlertController(title: "Location Not Provided", message: "A location has not been provided. Please either enter a location, or request to use the current location.", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Enter Location", style: .Default, handler: { _ in self.locationEntryField.becomeFirstResponder() } ))
            alert.addAction(UIAlertAction(title: "Use Current Location", style: .Default, handler: { _ in self.useCurrentLocationTapped(self) }))
            presentViewController(alert, animated: true, completion: nil)
            return
        }
        transitionToMapView()
    }
    
    @IBAction func submitTapped(sender: AnyObject)
    {
        guard urlEntry.text != nil && !urlEntry.text!.isEmpty else {
            let alert = UIAlertController(title: "URL Not Provided", message: "A URL has not been provided and is required to post data. Please provide a URL.", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: { _ in } ))
            presentViewController(alert, animated: true, completion: nil)
            return
        }
        if let user = UdacityClient.sharedInstance().user, let location = mapView.annotations.first as? MKPointAnnotation {
            
            let studentData = StudentData(objectId: nil,
                                          uniqueKey: "\(user.userId)",
                                          firstName: user.firstName,
                                          lastName: user.lastName,
                                          mapString: location.title!,
                                          mediaURL: urlEntry.text!,
                                          latitude: Float(location.coordinate.latitude),
                                          longitude: Float(location.coordinate.longitude))
            
            ParseClient.sharedInstance().postStudentData(studentData, overwritingPreviousValue: shouldOverwritePreviousPost) { (error) in
                NSLog("\(error)")
            }
        }
        else {
            NSLog("User not logged in, or location not provided")
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func useCurrentLocationTapped(sender: AnyObject)
    {
        if let currentLocation = locationManager.location {
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(currentLocation) { (placemarks, error) in
                guard error == nil else {
                    NSLog("\(error!)\n\(error!.localizedDescription)")
                    return
                }
                guard let placemarks = placemarks else {
                    let userInfo = [NSLocalizedDescriptionKey: "No placemarks returned."]
                    let newError = NSError(domain: "PostLinkViewController.useCurrentLocationTapped", code: 1, userInfo: userInfo)
                    NSLog("\(newError)\n\(newError.localizedDescription)")
                    return
                }
                if let placemark = placemarks.first {
                    self.transitionToMapView()
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = currentLocation.coordinate
                    annotation.title = placemark.name
                    self.locationEntryField.text = placemark.name
                    self.mapView.addAnnotation(annotation)
                    self.mapView.setRegion(MKCoordinateRegionMakeWithDistance(currentLocation.coordinate, 1000, 1000), animated: true)
                }
            }
        }
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
    
    // MARK: - Private Methods
    private func transitionToMapView()
    {
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
}

// MARK: - UITextViewDelegate Implementation
extension PostLinkViewController: UITextViewDelegate
{
    func textViewShouldBeginEditing(textView: UITextView) -> Bool
    {
        if textView.text == textFieldPlaceHolderText {
            textView.text = ""
            textView.textColor = UIColor.whiteColor()
        }
        return true
    }
    
    func textViewDidEndEditing(textView: UITextView)
    {
        if textView.text.isEmpty {
            textView.text = textFieldPlaceHolderText
            textView.textColor = UIColor.lightTextColor()
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool
    {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
