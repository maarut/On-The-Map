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
    @IBOutlet weak var mapView: MKMapView!
    private var studentLocations: [StudentLocation]?
    private var locationManager = CLLocationManager()
    
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

    private func updateLocationOnMap()
    {
        if let currentLocation = self.locationManager.location, studentLocations = self.studentLocations {
            dispatch_async(dispatch_get_main_queue()) {
                self.mapView.setRegion(self.coordinateRegionForStudentLocations(studentLocations, nearCurrentLocation: currentLocation), animated: true)
            }
        }
        else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC * 3)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), updateLocationOnMap)
        }
    }
    
    private func pinsForLocations() -> [MKPointAnnotation]
    {
        return studentLocations?.map {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees($0.latitude), longitude: CLLocationDegrees($0.longitude))
            annotation.title = "\($0.firstName) \($0.lastName)"
            annotation.subtitle = $0.mediaURL
            return annotation
        } ?? []
    }
    
    private func annotateMapView()
    {
        mapView.addAnnotations(pinsForLocations())
    }
    
    private func coordinateRegionForStudentLocations(studentLocations: [StudentLocation], nearCurrentLocation currentLocation: CLLocation) -> MKCoordinateRegion
    {
        let location = MKMapPointForCoordinate(currentLocation.coordinate)
        let mapCoordinates = studentLocations.map {
            MKMapPointForCoordinate(CLLocationCoordinate2DMake(CLLocationDegrees($0.latitude), CLLocationDegrees($0.longitude)))
        }
        let sortedCoordinates = mapCoordinates.sort {
            let distanceLHS = MKMetersBetweenMapPoints(location, $0)
            let distanceRHS = MKMetersBetweenMapPoints(location, $1)
            return distanceLHS < distanceRHS
        }
        var currentDistanceCheck = CLLocationDistance(1000000)
        let filteredCoordinates = sortedCoordinates.filter {
            let distance = MKMetersBetweenMapPoints(location, $0)
            if distance < currentDistanceCheck {
                currentDistanceCheck = distance + 1000000
                return true
            }
            return false
        }
        let maxX = filteredCoordinates.maxElement { $0.x < $1.x }?.x ?? 0.0
        let maxY = filteredCoordinates.maxElement { $0.y < $1.y }?.y ?? 0.0
        let furthestCoordinate = MKCoordinateForMapPoint(MKMapPointMake(maxX, maxY))
        let span = MKCoordinateSpanMake(abs(currentLocation.coordinate.latitude - furthestCoordinate.latitude), abs(currentLocation.coordinate.longitude - furthestCoordinate.longitude))
        return MKCoordinateRegionMake(currentLocation.coordinate, span)
    }
}

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
                    alertController.addAction(UIAlertAction(title: "Okay", style: .Default, handler: { _ in self.dismissViewControllerAnimated(true, completion: nil) }))
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
            }
            else {
                let alertController = UIAlertController(title: "Couldn't open URL", message: "URL \"\(view.annotation?.subtitle ?? "")\" is not a valid URL", preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: "Okay", style: .Default, handler: { _ in self.dismissViewControllerAnimated(true, completion: nil) }))
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

extension MapViewController: TabBarCommonOperations
{
    func refreshTapped(sender: AnyObject)
    {
        studentLocations = (UIApplication.sharedApplication().delegate as? AppDelegate)?.studentLocations
        annotateMapView()
    }
}