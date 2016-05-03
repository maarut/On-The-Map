//
//  MapViewController.swift
//  On The Map
//
//  Created by Maarut Chandegra on 03/05/2016.
//  Copyright © 2016 Maarut Chandegra. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController
{
    @IBOutlet weak var mapView: MKMapView!
    
}

extension MapViewController: MKMapViewDelegate {
    
}

extension MapViewController: TabBarCommonOperations {
    func refreshTapped(sender: AnyObject)
    {
        print("MapViewController refreshTapped")
    }
}