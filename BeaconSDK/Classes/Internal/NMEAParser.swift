//
//  NMEAParser.swift
//  ntrip
//
//  Created by Paul Himes on 1/10/15.
//  Copyright (c) 2015 Rolling Forks Design Group, LLC. All rights reserved.
//

import Foundation
import CoreLocation

class NMEAParser: NSObject {
    
    class func parse(input: String) -> ([GGA], [VTG], [GSV], String) {
        
        let (nmeaStrings, remainder) = NMEAParser.extractNMEAStringsFromWorkspace(input)
        
        var ggas: [GGA] = []
        var vtgs: [VTG] = []
        var gsvs: [GSV] = []
        
        for nmeaString in nmeaStrings {
            if let gga = GGA(nmeaString: nmeaString) {
                ggas.append(gga)
            }
            
            if let vtg = VTG(nmeaString: nmeaString) {
                vtgs.append(vtg)
            }
            
            if let gsv = GSV(nmeaString: nmeaString) {
                gsvs.append(gsv)
            }
        }
        
        return (ggas, vtgs, gsvs, remainder)
    }
    
    private class func extractNMEAStringsFromWorkspace(workspace: String) -> (strings: [String], remainder: String) {
        var nmeaStrings: [String] = []
        
        var nmeaStartIndex: String.Index?
        var currentIndex = workspace.startIndex
        
        let workspaceLength = workspace.characters.count
        
        for i in 0..<workspaceLength {
            if workspace[currentIndex] == "$" { // This index could be the start of a NMEA string.
                nmeaStartIndex = currentIndex
            } else if i >= 2 &&
                workspace[currentIndex.advancedBy(-2)] == "*" &&
                nmeaStartIndex != nil &&
                currentIndex.advancedBy(-2) > nmeaStartIndex { // This index is the end of a potential NMEA string.
                    nmeaStrings.append(workspace.substringWithRange(nmeaStartIndex!...currentIndex))
                    nmeaStartIndex = nil
            }
            
            if i < workspaceLength - 1 {
                currentIndex = currentIndex.successor()
            }
        }
        
        var remainder = ""
        if nmeaStartIndex != nil {
            remainder = workspace.substringFromIndex(nmeaStartIndex!)
        }
        
        // Filter out bad NMEA strings.
        nmeaStrings = nmeaStrings.filter({ (potentialNMEAString) -> Bool in
            return NMEA.isValidNMEAString(potentialNMEAString)
        })
        
        return (nmeaStrings, remainder)
    }

}

struct NMEA {

    static func isValidNMEAString(string: String) -> Bool {
        if string.characters.count < 4 {
            return false
        }
        
        let dataPortion = dataPortionOfNMEAString(string)
        let givenChecksum = string.substringFromIndex(string.endIndex.advancedBy(-2))
        let checksum = calculateChecksumOfString(dataPortion)
        
        return givenChecksum == checksum
    }
    
    static func calculateChecksumOfString(string: String) -> String {
        
        var check: UInt8 = 0
        for character in string.utf8 {
            check ^= character
        }
        
        let hexString = NSString(format: "%02X", check)
        
        return hexString as String
    }
    
    static func dataPortionOfNMEAString(nmeaString: String) -> String {
        if nmeaString.characters.count < 4 {
            return ""
        } else {
            return nmeaString.substringWithRange(nmeaString.startIndex.advancedBy(1)..<nmeaString.endIndex.advancedBy(-3))
        }
    }
    
    static func fieldsFromNMEAString(nmeaString: String) -> [String] {
        let dataPortion = dataPortionOfNMEAString(nmeaString)
        let fields = dataPortion.characters.split(allowEmptySlices: true) { $0 == "," }.map { String($0) }
        return fields
    }
    
    static func buildGGAStringWithLocation(location: CLLocation) -> String {
        
        let messageId = "GPGGA"
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: "UTC")
        dateFormatter.dateFormat = "HHmmss.SS"
        let timeString = dateFormatter.stringFromDate(location.timestamp)
        
        let (latitudeHours, latitudeMinutes) = hoursMinutesFromDegrees(location.coordinate.latitude)
        let (longitudeHours, longitudeMinutes) = hoursMinutesFromDegrees(location.coordinate.longitude)
        
        let latitudeHoursString = NSString(format: "%02d", latitudeHours)
        let latitudeMinutesString = NSString(format: "%07.4f", latitudeMinutes)
        let latitude = "\(latitudeHoursString)\(latitudeMinutesString)"
        
        let longitudeHoursString = NSString(format: "%03d", longitudeHours)
        let longitudeMinutesString = NSString(format: "%07.4f", longitudeMinutes)
        let longitude = "\(longitudeHoursString)\(longitudeMinutesString)"
        
        let northSouth = location.coordinate.latitude >= 0 ? "N" : "S"
        let eashWest = location.coordinate.longitude >= 0 ? "E" : "W"
        
        let fixType = 1
        
        let numberOfSatellites = 8 // Must be >= 5. Also referred to as space vehicles (SVs)
        let numberOfSatellitesString = NSString(format: "%02d", numberOfSatellites)
        
        let horizontalDilutionOfPrecision = 1.0 // must be <= 10.0
        
        let elevation = NSString(format: "%.3f", location.altitude)
        
        let heightOfGeoidAboveEllipsoid = -32.00 // Too difficult to calculate?
        
        let ggaString = "\(messageId),\(timeString),\(latitude),\(northSouth),\(longitude),\(eashWest),\(fixType),\(numberOfSatellitesString),\(horizontalDilutionOfPrecision),\(elevation),M,\(heightOfGeoidAboveEllipsoid),M,,"
        
        //        let exampleSentence = "$GPGGA,193758.00,4535.894533,N,09525.791710,W,2,07,1.1,371.113,M,-28.412,M,7.0,0138*7B"
        //        let exampleGGAString = "GPGGA,193758.00,4535.894533,N,09525.791710,W,2,07,1.1,371.113,M,-28.412,M,7.0,0138"
        //        let modifiedExampleGGAString = "GPGGA,203513.08,4452.4402,N,09331.0986,W,1,08,1.0,289.615,M,-32.0,M,,"
        
        let checksum = NMEA.calculateChecksumOfString(ggaString)
        let generatedString = "$\(ggaString)*\(checksum)"
        
        return generatedString
    }
    
    static func hoursMinutesFromDegrees(degrees: Double) -> (Int, Double) {
        let absDegrees = abs(degrees)
        let hours = Int(floor(absDegrees))
        let minutes = (absDegrees - Double(hours)) * 60
        return (hours, minutes)
    }
}