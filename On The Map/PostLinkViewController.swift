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
    
    var shouldOverwritePreviousPost: Bool?
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
            if canUseCurrentLocationButton {
                alert.addAction(UIAlertAction(title: "Use Current Location", style: .Default, handler: { _ in self.useCurrentLocationTapped(self) }))
            }
            presentViewController(alert, animated: true, completion: nil)
            return
        }
        findOnTheMapButton.enabled = false
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(locationEntryField.text!) { (placemarks, error) in
            self.findOnTheMapButton.enabled = true
            guard error == nil else {
                self.showErrorWithTitle("Error Occured", message: error!.localizedDescription)
                NSLog(error!.description)
                return
            }
            if let placemark = placemarks?.first { self.zoomToPlaceMark(placemark) }
            else { self.showErrorWithTitle("Error Occured", message: "No placemarks returned") }
        }
    }
    
    @IBAction func submitTapped(sender: AnyObject)
    {
        guard urlEntry.text != nil && !urlEntry.text!.isEmpty else {
            showErrorWithTitle("URL Not Provided", message: "A URL has not been provided and is required to post data. Please provide a URL.")
            return
        }
        let postData: (user: UdacityUser, annotation: MKPointAnnotation, shouldOverridePreviousPost: Bool) -> Void = { (user, annotation, shouldOverwritePreviousPost) in
            let studentData = StudentData(objectId: nil,
                                          uniqueKey: "\(user.userId)",
                                          firstName: user.firstName,
                                          lastName: user.lastName,
                                          mapString: annotation.title!,
                                          mediaURL: self.urlEntry.text!,
                                          latitude: Float(annotation.coordinate.latitude),
                                          longitude: Float(annotation.coordinate.longitude))
            
            ParseClient.sharedInstance().postStudentData(studentData, overwritingPreviousValue: shouldOverwritePreviousPost) { (error) in
                self.showErrorWithTitle("Unable To Post Data", message: error.localizedDescription)
                NSLog(error.description)
            }
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        if let user = UdacityClient.sharedInstance().user, let annotation = mapView.annotations.first as? MKPointAnnotation {
            if shouldOverwritePreviousPost == nil {
                switch StudentDataStore.currentlyLoggedInUsersPreviousPost {
                case .HasPosted:
                    let alertController = UIAlertController(title: "Overwrite Previous Location?", message: "You have previously posted a location at which you're studying. Would you like to update that post, or would you like to post a new location?", preferredStyle: .Alert)
                    let overwriteButton = UIAlertAction(title: "Overwrite", style: .Default, handler: { _ in postData(user: user, annotation: annotation, shouldOverridePreviousPost: true) })
                    let newButton = UIAlertAction(title: "New", style: .Default, handler: { _ in postData(user: user, annotation: annotation, shouldOverridePreviousPost: true) })
                    alertController.addAction(overwriteButton)
                    alertController.addAction(newButton)
                    presentViewController(alertController, animated: true, completion: nil)
                    break
                case .Undetermined:
                    postData(user: user, annotation: annotation, shouldOverridePreviousPost: true)
                    break
                case .NeverPosted:
                    postData(user: user, annotation: annotation, shouldOverridePreviousPost: false)
                    break
                }
            }
            else {
                postData(user: user, annotation: annotation, shouldOverridePreviousPost: shouldOverwritePreviousPost!)
            }
        }
        else {
            showErrorWithTitle("User Not Logged In", message: "There was an error during login and the user cannot be determined. Please logout and log back in to post your location.")
        }
    }
    
    @IBAction func useCurrentLocationTapped(sender: AnyObject)
    {
        if let currentLocation = locationManager.location {
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(currentLocation) { (placemarks, error) in
                guard error == nil else {
                    self.showErrorWithTitle("Error Occurred", message: error!.localizedDescription)
                    NSLog(error!.description)
                    return
                }
                if let placemark = placemarks?.first { self.zoomToPlaceMark(placemark) }
                else {
                    let userInfo = [NSLocalizedDescriptionKey: "No placemarks returned."]
                    let newError = NSError(domain: "PostLinkViewController.useCurrentLocationTapped", code: 1, userInfo: userInfo)
                    self.showErrorWithTitle("Error Occurred", message: newError.localizedDescription)
                    NSLog("\(newError.description)")
                }
            }
        }
        else {
            showErrorWithTitle("Unable To Determine Location", message: "The location couldn't be determined at this time. Please try again later, or enter your location manually.")
        }
    }
    
    @IBAction func cancelTapped(sender: AnyObject)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func tapRecognised(sender: UITapGestureRecognizer)
    {
        let tapLocation = locationEntryField.convertPoint(sender.locationInView(self.view), fromView: self.view)
        
        if !locationEntryField.hidden && !locationEntryField.pointInside(tapLocation, withEvent: nil) {
            locationEntryField.resignFirstResponder()
        }
        else if !urlEntry.hidden && !urlEntry.pointInside(tapLocation, withEvent: nil) {
            urlEntry.resignFirstResponder()
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
    
    private func zoomToPlaceMark(placemark: CLPlacemark)
    {
        transitionToMapView()
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.location!.coordinate
        annotation.title = placemark.name
        locationEntryField.text = placemark.name
        mapView.addAnnotation(annotation)
        mapView.setRegion(MKCoordinateRegionMakeWithDistance(placemark.location!.coordinate, 1000, 1000), animated: true)
    }
    
    private func showErrorWithTitle(title: String, message: String)
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .Default , handler: { _ in }))
        presentViewController(alertController, animated: true, completion: nil)
    }
}

// MARK: - UITextFieldDelegate Implementation
extension PostLinkViewController: UITextFieldDelegate
{
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        submitTapped(self)
        return true
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
            findLocationTapped(self)
            return false
        }
        return true
    }
}
