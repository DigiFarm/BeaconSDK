//
//  MapViewController.swift
//  BeaconSDKTestClient
//
//  Created by Paul Himes on 3/23/16.
//  Copyright © 2016 Glacial Ridge Technologies. All rights reserved.
//

import UIKit
import MapKit
import BeaconSDK

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    private var ggaObserver: NotificationObserver?
    private lazy var locationAnnotation: MKPointAnnotation = {
        let annotation = MKPointAnnotation()
        self.mapView.addAnnotation(annotation)
        return annotation
    }()
    private var lockOnLocation = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ggaObserver = NotificationObserver(notification: beaconGGANotification, queue: NSOperationQueue.mainQueue()) {
            [weak self] (gga) in
            if let latitude = gga.latitude, longitude = gga.longitude {
                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                self?.locationAnnotation.coordinate = coordinate
                
                if self?.lockOnLocation ?? false {
                    let span = MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
                    let region = MKCoordinateRegion(center: coordinate, span: span)
                    self?.mapView.setRegion(region, animated: true)
                    self?.lockOnLocation = false
                }
            }
        }
    }
}