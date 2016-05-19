//
//  MapViewController.swift
//  On The Map
//
//  Created by Maarut Chandegra on 03/05/2016.
//  Copyright © 2016 Maarut Chandegra. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController
{
    // MARK: - Instance Variables
    @IBOutlet weak var mapView: MKMapView!
    private var locationManager = CLLocationManager()

    // MARK: - Overrides
    override func viewDidLoad()
    {
        super.viewDidLoad()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        if !CLLocationManager.locationServicesEnabled() {
            let alertVC = UIAlertController(title: "Location Services Disabled", message: "Please enable location services before to be able to automatically select your location", preferredStyle: .Alert)
            alertVC.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { _ in self.dismissViewControllerAnimated(true, completion: nil) } ))
            alertVC.addAction(UIAlertAction(title: "Settings", style: .Default, handler: { _ in UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!) }))
            presentViewController(alertVC, animated: true, completion: nil)
        }
        switch CLLocationManager.authorizationStatus() {
        case .NotDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .Denied:
            let alertVC = UIAlertController(title: "Location Services Denied", message: "Please enable location services for On The Map to be able to automatically select your location", preferredStyle: .Alert)
            alertVC.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { _ in self.dismissViewControllerAnimated(true, completion: nil) } ))
            alertVC.addAction(UIAlertAction(title: "Settings", style: .Default, handler: { _ in UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!) }))
            presentViewController(alertVC, animated: true, completion: nil)
            break
        case .Restricted:
            let alertVC = UIAlertController(title: "Location Services Restricted", message: "Please speak to your device manager to enable location services for On The Map to be able to automatically select your location", preferredStyle: .Alert)
            alertVC.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { _ in self.dismissViewControllerAnimated(true, completion: nil) } ))
            presentViewController(alertVC, animated: true, completion: nil)
            break
        default:
            break
        }
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        updateLocationOnMap()
    }

    // MARK: - Private Methods
    private func updateLocationOnMap()
    {
        let currentLocation = locationManager.location
        if currentLocation != nil && !StudentDataStore.studentData.isEmpty {
            onMainQueueDo {
                self.mapView.setRegion(self.coordinateRegionForStudentData(
                    StudentDataStore.studentData, nearCurrentLocation: currentLocation!),
                                       animated: true)
            }
        }
        else {
            after(3.seconds(), executeBlock: updateLocationOnMap)
        }
    }
    
    private func pinsForLocations() -> [MKPointAnnotation]
    {
        return StudentDataStore.studentData.map {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees($0.latitude), longitude: CLLocationDegrees($0.longitude))
            annotation.title = "\($0.firstName) \($0.lastName)"
            annotation.subtitle = $0.mediaURL
            return annotation
        } ?? []
    }
    
    private func coordinateRegionForStudentData(studentData: [StudentData], nearCurrentLocation currentLocation: CLLocation) -> MKCoordinateRegion
    {
        let coordinates = StudentDataStore.studentDataSurroundingLocation(currentLocation).map {
            CLLocationCoordinate2D(latitude: CLLocationDegrees($0.latitude), longitude: CLLocationDegrees($0.longitude))
        }
        return MKCoordinateRegionMake(regionSpanningCoordinates: coordinates, centeringOn: currentLocation.coordinate)
    }
}


// MARK: - CLLocationManagerDelegate Implementation
extension MapViewController: CLLocationManagerDelegate
{
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus)
    {
        if status == .AuthorizedAlways || status == .AuthorizedWhenInUse {
            updateLocationOnMap()
        }
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError)
    {
        NSLog(error.localizedDescription)
    }
}

// MARK: - MKMapViewDelegate Implementation
extension MapViewController: MKMapViewDelegate
{
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl)
    {
        if control == view.rightCalloutAccessoryView {
            if let urlStr = view.annotation?.subtitle, url = NSURL(string: urlStr!) {
                let sharedApp = UIApplication.sharedApplication()
                if sharedApp.canOpenURL(url) {
                    sharedApp.openURL(url)
                }
                else {
                    let alertController = UIAlertController(title: "Couldn't open URL", message: "The system was not able to open URL - \"\(urlStr)\"", preferredStyle: .Alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: { _ in self.dismissViewControllerAnimated(true, completion: nil) }))
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
            }
            else {
                let alertController = UIAlertController(title: "Couldn't open URL", message: "URL \"\(view.annotation?.subtitle ?? "")\" is not a valid URL", preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: { _ in self.dismissViewControllerAnimated(true, completion: nil) }))
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView?
    {
        if annotation.isKindOfClass(MKUserLocation) { return nil }
        
        let reuseId = "pinView"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView != nil {
            pinView!.annotation = annotation
        }
        else {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        return pinView
    }
}

// MARK: - TabBarCommonOperations Implementation
extension MapViewController: TabBarCommonOperations
{
    func refreshTapped(sender: AnyObject)
    {
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(pinsForLocations())
    }
}