//
//  PublicTypes.swift
//  BeaconSDK
//
//  Created by Paul Himes on 5/24/16.
//  Copyright © 2016 Glacial Ridge Technologies. All rights reserved.
//

import CoreLocation

public class GGA: NSObject {
    public let nmeaString: String
    public let utcTime: NSDate?
    public let latitude: Double?
    public let longitude: Double?
    public let gpsQuality: GPSQuality?
    public let numberOfSVsInUse: Int?
    public let hdop: Double?
    public let orthometricHeight: Double?
    public let geoidSeparation: Double?
    public let ageOfDifferentialGPSDataRecord: Double?
    public let referenceStationId: Int?
    
    init?(nmeaString: String) {
        self.nmeaString = nmeaString
        
        let fields = NMEA.fieldsFromNMEAString(nmeaString)
        
        if fields.count < 15 {
            self.utcTime = nil
            self.latitude = nil
            self.longitude = nil
            self.gpsQuality = nil
            self.numberOfSVsInUse = nil
            self.hdop = nil
            self.orthometricHeight = nil
            self.geoidSeparation = nil
            self.ageOfDifferentialGPSDataRecord = nil
            self.referenceStationId = nil
            super.init()
            return nil
        }
        
        if fields[0].lowercaseString != "gpgga" {
            self.utcTime = nil
            self.latitude = nil
            self.longitude = nil
            self.gpsQuality = nil
            self.numberOfSVsInUse = nil
            self.hdop = nil
            self.orthometricHeight = nil
            self.geoidSeparation = nil
            self.ageOfDifferentialGPSDataRecord = nil
            self.referenceStationId = nil
            super.init()
            return nil
        }
        
        let timeFormatter = NSDateFormatter()
        timeFormatter.dateFormat = "HHmmss.SS"
        timeFormatter.timeZone = NSTimeZone(name: "UTC")
        let time = timeFormatter.dateFromString(fields[1])
        
        let numberFormatter = NSNumberFormatter()
        
        var latitude: Double?
        if let degreesMinutesLatitude = numberFormatter.numberFromString(fields[2]) {
            let degrees = floor(degreesMinutesLatitude.doubleValue / 100)
            let minutes = degreesMinutesLatitude.doubleValue - degrees * 100
            latitude = (degrees + minutes / 60) * (fields[3] == "N" ? 1 : -1)
        }
        var longitude: Double?
        if let degreesMinutesLongitude = numberFormatter.numberFromString(fields[4]) {
            let degrees = floor(degreesMinutesLongitude.doubleValue / 100)
            let minutes = degreesMinutesLongitude.doubleValue - degrees * 100
            longitude = (degrees + minutes / 60) * (fields[5] == "E" ? 1 : -1)
        }
        
        var gpsQuality: GPSQuality?
        if let qualityInt = Int(fields[6]) {
            gpsQuality = GPSQuality(rawValue: qualityInt)
        }
        
        let numberOfSpaceVehicles = Int(fields[7])
        
        let horizontalDilutionOfPrecision = numberFormatter.numberFromString(fields[8])?.doubleValue
        
        let heightOfAntennaAboveMeanSeaLevel = numberFormatter.numberFromString(fields[9])?.doubleValue
        
        let heightOfGeoidAboveEllipsoid = numberFormatter.numberFromString(fields[11])?.doubleValue
        
        let ageOfDifferentialGPSDataRecord = numberFormatter.numberFromString(fields[13])?.doubleValue
        
        let baseStationId = numberFormatter.numberFromString(fields[14])?.integerValue
        
        self.utcTime = time
        self.latitude = latitude
        self.longitude = longitude
        self.gpsQuality = gpsQuality
        self.numberOfSVsInUse = numberOfSpaceVehicles
        self.hdop = horizontalDilutionOfPrecision
        self.orthometricHeight = heightOfAntennaAboveMeanSeaLevel
        self.geoidSeparation = heightOfGeoidAboveEllipsoid
        self.ageOfDifferentialGPSDataRecord = ageOfDifferentialGPSDataRecord
        self.referenceStationId = baseStationId
        
        super.init()
    }
    
    convenience init?(location: CLLocation) {
        self.init(nmeaString: NMEA.buildGGAStringWithLocation(location))
    }
    
    override public var description: String {
        var description = ""
        
        if utcTime != nil {
            let formatter = NSDateFormatter()
            formatter.dateStyle = .NoStyle
            formatter.timeStyle = .LongStyle
            formatter.timeZone = NSTimeZone(name: "UTC")
            description += "utcTime = \(formatter.stringFromDate(utcTime!))\n"
        }
        
        if latitude != nil {
            description += "latitude = \(latitude!)\n"
        }
        
        if longitude != nil {
            description += "longitude = \(longitude!)\n"
        }
        
        if gpsQuality != nil {
            description += "gpsQuality = \(gpsQuality!)\n"
        }
        
        if numberOfSVsInUse != nil {
            description += "numberOfSVsInUse = \(numberOfSVsInUse!)\n"
        }
        
        if hdop != nil {
            description += "hdop = \(hdop!)\n"
        }
        
        if orthometricHeight != nil {
            description += "orthometricHeight = \(orthometricHeight!)\n"
        }
        
        if geoidSeparation != nil {
            description += "geoidSeparation = \(geoidSeparation!)\n"
        }
        
        if ageOfDifferentialGPSDataRecord != nil {
            description += "ageOfDifferentialGPSDataRecord = \(ageOfDifferentialGPSDataRecord!)\n"
        }
        
        if referenceStationId != nil {
            description += "referenceStationId = \(referenceStationId!)\n"
        }
        
        return description
    }
}

@objc public enum GPSQuality: Int, CustomStringConvertible {
    case FixNotValid = 0
    case GPSFix = 1
    case DifferentialGPSFix = 2
    case PPSFix = 3
    case RealTimeKinematicFixedIntegers = 4
    case RealTimeKinematicFloatIntegers = 5
    case EstimatedFix = 6
    case ManualInputMode = 7
    case SimulationMode = 8
    case WAASFix = 9
    
    public var description: String {
        get {
            var description = ""
            
            switch self {
            case FixNotValid:
                description += "Not Valid"
            case GPSFix:
                description += "GPS"
            case DifferentialGPSFix:
                description += "DGPS"
            case PPSFix:
                description += "PPS Fix"
            case RealTimeKinematicFixedIntegers:
                description += "RTK Fixed Integers"
            case RealTimeKinematicFloatIntegers:
                description += "RTK Float Integers"
            case EstimatedFix:
                description += "Estimated"
            case ManualInputMode:
                description += "Manual Input"
            case SimulationMode:
                description += "Simulation"
            case WAASFix:
                description += "WAAS"
            }
            
            return description
        }
    }
}

public class VTG: NSObject {
    public let nmeaString: String
    public let trueTrackMadeGoodDegrees: Double?
    public let magneticTrackMadeGoodDegrees: Double?
    public let speedOverGroundInKnots: Double?
    public let speedOverGroundInKilometersPerHour: Double?
    
    init?(nmeaString: String) {
        self.nmeaString = nmeaString
        
        let fields = NMEA.fieldsFromNMEAString(nmeaString)
        
        if fields.count < 9 {
            self.trueTrackMadeGoodDegrees = nil
            self.magneticTrackMadeGoodDegrees = nil
            self.speedOverGroundInKnots = nil
            self.speedOverGroundInKilometersPerHour = nil
            super.init()
            return nil
        }
        
        if fields[0].lowercaseString != "gpvtg" {
            self.trueTrackMadeGoodDegrees = nil
            self.magneticTrackMadeGoodDegrees = nil
            self.speedOverGroundInKnots = nil
            self.speedOverGroundInKilometersPerHour = nil
            super.init()
            return nil
        }
        
        let numberFormatter = NSNumberFormatter()
        
        let trueTrackMadeGoodDegrees = numberFormatter.numberFromString(fields[1])?.doubleValue
        
        let magneticTrackMadeGoodDegrees = numberFormatter.numberFromString(fields[3])?.doubleValue
        
        let speedOverGroundInKnots = numberFormatter.numberFromString(fields[5])?.doubleValue
        
        let speedOverGroundInKilometersPerHour = numberFormatter.numberFromString(fields[7])?.doubleValue
        
        self.trueTrackMadeGoodDegrees = trueTrackMadeGoodDegrees
        self.magneticTrackMadeGoodDegrees = magneticTrackMadeGoodDegrees
        self.speedOverGroundInKnots = speedOverGroundInKnots
        self.speedOverGroundInKilometersPerHour = speedOverGroundInKilometersPerHour
        
        super.init()
    }
    
    override public var description: String {
        var description = ""
        
        if trueTrackMadeGoodDegrees != nil {
            description += "trueTrackMadeGoodDegrees = \(trueTrackMadeGoodDegrees!)\n"
        }
        
        if magneticTrackMadeGoodDegrees != nil {
            description += "magneticTrackMadeGoodDegrees = \(magneticTrackMadeGoodDegrees!)\n"
        }
        
        if speedOverGroundInKnots != nil {
            description += "speedOverGroundInKnots = \(speedOverGroundInKnots!)\n"
        }
        
        if speedOverGroundInKilometersPerHour != nil {
            description += "speedOverGroundInKilometersPerHour = \(speedOverGroundInKilometersPerHour!)\n"
        }
        
        return description
    }
}

public class GSVSatellite: NSObject {
    public let prnNumber: Int
    public let elevationDegree: Int
    public let azimuthDegree: Int
    public let signalToNoiseRatio: Int?
    
    init(prnNumber: Int, elevationDegree: Int, azimuthDegree: Int, signalToNoiseRatio: Int?) {
        self.prnNumber = prnNumber
        self.elevationDegree = elevationDegree
        self.azimuthDegree = azimuthDegree
        self.signalToNoiseRatio = signalToNoiseRatio
    }
    
    override public var description: String {
        var description = ""
        
        description += "prnNumber = \(prnNumber)\n"
        description += "elevationDegree = \(elevationDegree)\n"
        description += "azimuthDegree = \(azimuthDegree)\n"
        
        if signalToNoiseRatio != nil {
            description += "signalToNoiseRatio = \(signalToNoiseRatio!)\n"
        }
        
        return description
    }
}

public class GSV: NSObject {
    public let nmeaString: String
    public let totalNumberOfMessagesInThisCycle: Int?
    public let messageNumber: Int?
    public let totalNumberOfSVsVisible: Int?
    public let gsvSatellites: [GSVSatellite]?
    
    
    init?(nmeaString: String) {
        self.nmeaString = nmeaString
        
        let fields = NMEA.fieldsFromNMEAString(nmeaString)
        
        if fields.count < 20 {
            return nil
        }
        
        if fields[0].lowercaseString != "gpgsv" {
            return nil
        }
        
        let numberFormatter = NSNumberFormatter()
        
        totalNumberOfMessagesInThisCycle = numberFormatter.numberFromString(fields[1])?.integerValue
        
        messageNumber = numberFormatter.numberFromString(fields[2])?.integerValue
        
        totalNumberOfSVsVisible = numberFormatter.numberFromString(fields[3])?.integerValue
        
        var satellites: [GSVSatellite] = []
        
        // First satellite slot
        if let prnNumber = numberFormatter.numberFromString(fields[4])?.integerValue,
            elevationDegree = numberFormatter.numberFromString(fields[5])?.integerValue,
            azimuthDegree = numberFormatter.numberFromString(fields[6])?.integerValue {
            
            let signalToNoiseRation = numberFormatter.numberFromString(fields[7])?.integerValue
            
            satellites.append(GSVSatellite(prnNumber: prnNumber, elevationDegree: elevationDegree, azimuthDegree: azimuthDegree, signalToNoiseRatio: signalToNoiseRation))
        }
        
        // Second satellite slot
        if let prnNumber = numberFormatter.numberFromString(fields[8])?.integerValue,
            elevationDegree = numberFormatter.numberFromString(fields[9])?.integerValue,
            azimuthDegree = numberFormatter.numberFromString(fields[10])?.integerValue {
            
            let signalToNoiseRation = numberFormatter.numberFromString(fields[11])?.integerValue
            
            satellites.append(GSVSatellite(prnNumber: prnNumber, elevationDegree: elevationDegree, azimuthDegree: azimuthDegree, signalToNoiseRatio: signalToNoiseRation))
        }
        
        // Third satellite slot
        if let prnNumber = numberFormatter.numberFromString(fields[12])?.integerValue,
            elevationDegree = numberFormatter.numberFromString(fields[13])?.integerValue,
            azimuthDegree = numberFormatter.numberFromString(fields[14])?.integerValue {
            
            let signalToNoiseRation = numberFormatter.numberFromString(fields[15])?.integerValue
            
            satellites.append(GSVSatellite(prnNumber: prnNumber, elevationDegree: elevationDegree, azimuthDegree: azimuthDegree, signalToNoiseRatio: signalToNoiseRation))
        }
        
        // Fourth satellite slot
        if let prnNumber = numberFormatter.numberFromString(fields[16])?.integerValue,
            elevationDegree = numberFormatter.numberFromString(fields[17])?.integerValue,
            azimuthDegree = numberFormatter.numberFromString(fields[18])?.integerValue {
            
            let signalToNoiseRation = numberFormatter.numberFromString(fields[19])?.integerValue
            
            satellites.append(GSVSatellite(prnNumber: prnNumber, elevationDegree: elevationDegree, azimuthDegree: azimuthDegree, signalToNoiseRatio: signalToNoiseRation))
        }
        
        gsvSatellites = satellites
        
        super.init()
    }
    
    override public var description: String {
        var description = ""
        
        if totalNumberOfMessagesInThisCycle != nil {
            description += "totalNumberOfMessagesInThisCycle = \(totalNumberOfMessagesInThisCycle!)\n"
        }
        
        if messageNumber != nil {
            description += "messageNumber = \(messageNumber!)\n"
        }
        
        if totalNumberOfSVsVisible != nil {
            description += "totalNumberOfSVsVisible = \(totalNumberOfSVsVisible!)\n"
        }
        
        if let gsvSatellites = gsvSatellites {
            for gsvSatellite in gsvSatellites {
                description += "prnNumber = \(gsvSatellite.prnNumber)\n"
                description += "elevationDegree = \(gsvSatellite.elevationDegree)\n"
                description += "azimuthDegree = \(gsvSatellite.azimuthDegree)\n"
                
                if let signalToNoiseRatio = gsvSatellite.signalToNoiseRatio {
                    description += "signalToNoiseRatio = \(signalToNoiseRatio)\n"
                }
            }
        }
        
        return description
    }
}