//
//  MKCoordinateRegion+utils.swift
//  On The Map
//
//  Created by Maarut Chandegra on 10/05/2016.
//  Copyright © 2016 Maarut Chandegra. All rights reserved.
//

import MapKit

func MKCoordinateRegionMake(regionSpanningCoordinates coordinates: [CLLocationCoordinate2D], centeringOn center: CLLocationCoordinate2D) -> MKCoordinateRegion
{
    let mapCoordinates = coordinates.map { MKMapPointForCoordinate($0) }
    let maxX = mapCoordinates.maxElement { $0.x < $1.x }?.x ?? 0.0
    let maxY = mapCoordinates.maxElement { $0.y < $1.y }?.y ?? 0.0
    let furthestCoordinate = MKCoordinateForMapPoint(MKMapPointMake(maxX, maxY))
    let span = MKCoordinateSpanMake(abs(center.latitude - furthestCoordinate.latitude), abs(center.longitude - furthestCoordinate.longitude))
    return MKCoordinateRegionMake(center, span)
}