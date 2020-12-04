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
    public let utcTime: Date?
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
        
        if fields[0].lowercased() != "gpgga" {
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
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HHmmss.SS"
        timeFormatter.timeZone = TimeZone(identifier: "UTC")
        let time = timeFormatter.date(from: fields[1])
        
        let numberFormatter = NumberFormatter()
        
        var latitude: Double?
        if let degreesMinutesLatitude = numberFormatter.number(from: fields[2]) {
            let degrees = floor(degreesMinutesLatitude.doubleValue / 100)
            let minutes = degreesMinutesLatitude.doubleValue - degrees * 100
            latitude = (degrees + minutes / 60) * (fields[3] == "N" ? 1 : -1)
        }
        var longitude: Double?
        if let degreesMinutesLongitude = numberFormatter.number(from: fields[4]) {
            let degrees = floor(degreesMinutesLongitude.doubleValue / 100)
            let minutes = degreesMinutesLongitude.doubleValue - degrees * 100
            longitude = (degrees + minutes / 60) * (fields[5] == "E" ? 1 : -1)
        }
        
        var gpsQuality: GPSQuality?
        if let qualityInt = Int(fields[6]) {
            gpsQuality = GPSQuality(rawValue: qualityInt)
        }
        
        let numberOfSpaceVehicles = Int(fields[7])
        
        let horizontalDilutionOfPrecision = numberFormatter.number(from: fields[8])?.doubleValue
        
        let heightOfAntennaAboveMeanSeaLevel = numberFormatter.number(from: fields[9])?.doubleValue
        
        let heightOfGeoidAboveEllipsoid = numberFormatter.number(from: fields[11])?.doubleValue
        
        let ageOfDifferentialGPSDataRecord = numberFormatter.number(from: fields[13])?.doubleValue
        
        let baseStationId = numberFormatter.number(from: fields[14])?.intValue
        
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
            let formatter = DateFormatter()
            formatter.dateStyle = .none
            formatter.timeStyle = .long
            formatter.timeZone = TimeZone(identifier: "UTC")
            description += "utcTime = \(formatter.string(from: utcTime!))\n"
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
    case fixNotValid = 0
    case gpsFix = 1
    case differentialGPSFix = 2
    case ppsFix = 3
    case realTimeKinematicFixedIntegers = 4
    case realTimeKinematicFloatIntegers = 5
    case estimatedFix = 6
    case manualInputMode = 7
    case simulationMode = 8
    case waasFix = 9
    
    public var description: String {
        get {
            var description = ""
            
            switch self {
            case .fixNotValid:
                description += "Not Valid"
            case .gpsFix:
                description += "GPS"
            case .differentialGPSFix:
                description += "DGPS"
            case .ppsFix:
                description += "PPS Fix"
            case .realTimeKinematicFixedIntegers:
                description += "RTK Fixed Integers"
            case .realTimeKinematicFloatIntegers:
                description += "RTK Float Integers"
            case .estimatedFix:
                description += "Estimated"
            case .manualInputMode:
                description += "Manual Input"
            case .simulationMode:
                description += "Simulation"
            case .waasFix:
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
        
        if fields[0].lowercased() != "gpvtg" {
            self.trueTrackMadeGoodDegrees = nil
            self.magneticTrackMadeGoodDegrees = nil
            self.speedOverGroundInKnots = nil
            self.speedOverGroundInKilometersPerHour = nil
            super.init()
            return nil
        }
        
        let numberFormatter = NumberFormatter()
        
        let trueTrackMadeGoodDegrees = numberFormatter.number(from: fields[1])?.doubleValue
        
        let magneticTrackMadeGoodDegrees = numberFormatter.number(from: fields[3])?.doubleValue
        
        let speedOverGroundInKnots = numberFormatter.number(from: fields[5])?.doubleValue
        
        let speedOverGroundInKilometersPerHour = numberFormatter.number(from: fields[7])?.doubleValue
        
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
        
        if fields[0].lowercased() != "gpgsv" {
            return nil
        }
        
        let numberFormatter = NumberFormatter()
        
        totalNumberOfMessagesInThisCycle = numberFormatter.number(from: fields[1])?.intValue
        
        messageNumber = numberFormatter.number(from: fields[2])?.intValue
        
        totalNumberOfSVsVisible = numberFormatter.number(from: fields[3])?.intValue
        
        var satellites: [GSVSatellite] = []
        
        // First satellite slot
        if let prnNumber = numberFormatter.number(from: fields[4])?.intValue,
            let elevationDegree = numberFormatter.number(from: fields[5])?.intValue,
            let azimuthDegree = numberFormatter.number(from: fields[6])?.intValue {
            
            let signalToNoiseRation = numberFormatter.number(from: fields[7])?.intValue
            
            satellites.append(GSVSatellite(prnNumber: prnNumber, elevationDegree: elevationDegree, azimuthDegree: azimuthDegree, signalToNoiseRatio: signalToNoiseRation))
        }
        
        // Second satellite slot
        if let prnNumber = numberFormatter.number(from: fields[8])?.intValue,
            let elevationDegree = numberFormatter.number(from: fields[9])?.intValue,
            let azimuthDegree = numberFormatter.number(from: fields[10])?.intValue {
            
            let signalToNoiseRation = numberFormatter.number(from: fields[11])?.intValue
            
            satellites.append(GSVSatellite(prnNumber: prnNumber, elevationDegree: elevationDegree, azimuthDegree: azimuthDegree, signalToNoiseRatio: signalToNoiseRation))
        }
        
        // Third satellite slot
        if let prnNumber = numberFormatter.number(from: fields[12])?.intValue,
            let elevationDegree = numberFormatter.number(from: fields[13])?.intValue,
            let azimuthDegree = numberFormatter.number(from: fields[14])?.intValue {
            
            let signalToNoiseRation = numberFormatter.number(from: fields[15])?.intValue
            
            satellites.append(GSVSatellite(prnNumber: prnNumber, elevationDegree: elevationDegree, azimuthDegree: azimuthDegree, signalToNoiseRatio: signalToNoiseRation))
        }
        
        // Fourth satellite slot
        if let prnNumber = numberFormatter.number(from: fields[16])?.intValue,
            let elevationDegree = numberFormatter.number(from: fields[17])?.intValue,
            let azimuthDegree = numberFormatter.number(from: fields[18])?.intValue {
            
            let signalToNoiseRation = numberFormatter.number(from: fields[19])?.intValue
            
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
