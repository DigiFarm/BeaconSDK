//
//  SatelliteViewController.swift
//  BeaconSDKTestClient
//
//  Created by Paul Himes on 4/13/16.
//  Copyright © 2016 Glacial Ridge Technologies. All rights reserved.
//

import UIKit
import BeaconSDK

class SatelliteViewController: UIViewController {

    private var gsvObserver: NotificationObserver?

    @IBOutlet weak var skyplotView: SkyplotView!
    
    private var temporarySatellites = [GSVSatellite]()
    private var satellites = [GSVSatellite]() {
        didSet {
            let markers = satellites.map{ SkyplotMarker(label: "\($0.prnNumber)", azimuth: Double($0.azimuthDegree), elevation: Double($0.elevationDegree)) }
            skyplotView.markers = markers
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gsvObserver = NotificationObserver(notification: beaconGSVNotification, queue: OperationQueue.main) { [weak self] (gsv) in
            guard let messageNumber = gsv.messageNumber else { return }
            guard let stelf = self else { return }
            
            // Add these satellites to the set.
            if let gsvSatellites = gsv.gsvSatellites {
                stelf.temporarySatellites.append(contentsOf: gsvSatellites)
            }
            
            // Complete the set of satellites by moving them to the main satellites arrey for display.
            if messageNumber == gsv.totalNumberOfMessagesInThisCycle {
                stelf.satellites = stelf.temporarySatellites
                stelf.temporarySatellites.removeAll()
            }
        }
    }
}
