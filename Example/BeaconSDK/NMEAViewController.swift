//
//  NMEAViewController.swift
//  BeaconSDKTestClient
//
//  Created by Paul Himes on 3/26/16.
//  Copyright © 2016 Glacial Ridge Technologies. All rights reserved.
//

import UIKit

class NMEAViewController: UITableViewController {

    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var fixTypeLabel: UILabel!
    @IBOutlet weak var numberOfSatellitesLabel: UILabel!
    @IBOutlet weak var hdopLabel: UILabel!
    @IBOutlet weak var orthometricHeightLabel: UILabel!
    @IBOutlet weak var geoidSeparationLabel: UILabel!
    @IBOutlet weak var ageOfDGPSDataRecordLabel: UILabel!
    @IBOutlet weak var stationIDLabel: UILabel!
    @IBOutlet weak var trueTrackMadeGoodLabel: UILabel!
    @IBOutlet weak var magneticTrackMadeGoodLabel: UILabel!
    @IBOutlet weak var speedOverGroundLabel: UILabel!
    
    private var ggaObserver: NotificationObserver?
    private var vtgObserver: NotificationObserver?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ggaObserver = NotificationObserver(notification: beaconGGANotification, queue: NSOperationQueue.mainQueue()){ [unowned self] (gga) in
            // Update gga labels
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = .NoStyle
            dateFormatter.timeStyle = .LongStyle
            dateFormatter.timeZone = NSTimeZone(name: "UTC")
            
            let correctionAgeFormatter = NSNumberFormatter()
            correctionAgeFormatter.roundingMode = NSNumberFormatterRoundingMode.RoundHalfEven
            
            self.timestampLabel.text = gga.utcTime != nil ? dateFormatter.stringFromDate((gga.utcTime)!) : ""
            
            self.latitudeLabel.text = gga.latitude != nil ? String(format: "%.7f", (gga.latitude)!) : ""
            self.longitudeLabel.text = gga.longitude != nil ? String(format: "%.7f", (gga.longitude)!) : ""
            
            self.fixTypeLabel.text = gga.gpsQuality != nil ? "\(gga.gpsQuality!)" : ""
            
            self.numberOfSatellitesLabel.text = gga.numberOfSVsInUse != nil ? "\((gga.numberOfSVsInUse)!)" : ""
            
            self.hdopLabel.text = gga.hdop != nil ? "\((gga.hdop)!)" : ""
            
            self.orthometricHeightLabel.text = gga.orthometricHeight != nil ? "\((gga.orthometricHeight)!) M" : ""
            
            self.geoidSeparationLabel.text = gga.geoidSeparation != nil ? "\((gga.geoidSeparation)!) M" : ""
            
            if let age = gga.ageOfDifferentialGPSDataRecord, correctionAgeString = correctionAgeFormatter.stringFromNumber(age) {
                self.ageOfDGPSDataRecordLabel?.text = "\(correctionAgeString)s"
            } else {
                self.ageOfDGPSDataRecordLabel?.text = ""
            }
            
            self.stationIDLabel.text = gga.referenceStationId != nil ? "\((gga.referenceStationId)!)" : ""
        }
        
        vtgObserver = NotificationObserver(notification: beaconVTGNotification, queue: NSOperationQueue.mainQueue()) { [unowned self] (vtg) in
            //Update vtg labels
            self.trueTrackMadeGoodLabel.text = vtg.trueTrackMadeGoodDegrees != nil ? "\(vtg.trueTrackMadeGoodDegrees!)°" : ""
            
            self.magneticTrackMadeGoodLabel.text = vtg.magneticTrackMadeGoodDegrees != nil ? "\(vtg.magneticTrackMadeGoodDegrees!)°" : ""
            
            self.speedOverGroundLabel.text = vtg.speedOverGroundInKilometersPerHour != nil ? "\(vtg.speedOverGroundInKilometersPerHour!)" : ""
        }
    }
}
