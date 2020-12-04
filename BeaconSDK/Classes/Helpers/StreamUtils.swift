//
//  StreamUtils.swift
//  ntrip
//
//  Created by Paul Himes on 2/21/15.
//  Copyright (c) 2015 Rolling Forks Design Group, LLC. All rights reserved.
//

import Foundation

let MB = 1048576

extension Stream {
    var statusString: String {
        get {
            switch streamStatus {
            case .notOpen:
                return "Not Open"
            case .opening:
                return "Opening"
            case .open:
                return "Open"
            case .reading:
                return "Reading"
            case .writing:
                return "Writing"
            case .atEnd:
                return "At End"
            case .closed:
                return "Closed"
            case .error:
                return "Error"
            @unknown default:
                return "Unknown"
            }
        }
    }
}

extension Data {
    func hexString() -> NSString {
        let str = NSMutableString()
        
        var iterater = makeIterator()
        var byte = iterater.next()
        while byte != nil {
            str.appendFormat("%02hhx", byte!)
            byte = iterater.next()
        }
        
        return str
    }
    
    func dataByAppendingData(_ data: Data, fifoLimit: Int = 0) -> Data {
        var combinedBuffer = self
        combinedBuffer.append(data)
        
        if fifoLimit > 0 && combinedBuffer.count > fifoLimit {
            DebugManager.log("Error: Buffer Overflow")
            // Return only the fifoLimit number of bytes from the end of the data.
            return combinedBuffer.subdata(in: combinedBuffer.index(combinedBuffer.endIndex, offsetBy: -fifoLimit)..<combinedBuffer.endIndex)
        }
        
        return combinedBuffer
    }
    
    func dataByAppendingBytes(_ bytes: UnsafePointer<UInt8>, length: Int, fifoLimit: Int = 0) -> Data {
        var combinedBuffer = self
        combinedBuffer.append(bytes, count: length)
        
        if fifoLimit > 0 && combinedBuffer.count > fifoLimit {
            DebugManager.log("Error: Buffer Overflow")
            // Return only the fifoLimit number of bytes from the end of the data.
            return combinedBuffer.subdata(in: combinedBuffer.index(combinedBuffer.endIndex, offsetBy: -fifoLimit)..<combinedBuffer.endIndex)
        }
        
        return combinedBuffer
    }
    
    // Splits the data using the given separator data.
    // An empty preceeding data IS included if the delimiter appears at the beginning of this data.
    // An empty trailing data is NOT included if the delimiter appears at the end of this data.
    // If the separator does not appear anywhere, the original data is returned as a single component.
    func componentsSeparatedByData(_ data: Data) -> [Data] {
        
        var components = [Data]()
        
        var searchRangeLocation = startIndex
        
        while searchRangeLocation < endIndex {
            let searchRange = searchRangeLocation..<endIndex
            if let separatorRange = range(of: data, options: [], in: searchRange) {
                let componentRange = searchRange.lowerBound..<separatorRange.lowerBound
                components.append(subdata(in: componentRange))
                searchRangeLocation = separatorRange.upperBound
            } else {
                components.append(subdata(in: searchRange))
                break
            }
        }
        
        return components
    }
    
    func endsWithData(_ data: Data) -> Bool {
        if data.count > count {
            return false
        }
        
        let searchRange = index(endIndex, offsetBy: -data.count)..<endIndex
        
        if range(of: data, options: [], in: searchRange) != nil {
            return true
        } else {
            return false
        }
    }
    
    func endsWithHex(_ hex: String) -> Bool {
        return endsWithData(hex.dataFromHexString()!)
    }
    
    func toString() -> String? {
        return String(data: self, encoding: .utf8)
    }
}

extension String {
    func toData() -> Data? {
        return data(using: .utf8, allowLossyConversion: false)
    }
    
    func dataFromHexString() -> Data? {
        
        let data = NSMutableData()
        
        var currentIndex = startIndex
        while currentIndex < index(endIndex, offsetBy: -1) {
            let substring = String(self[currentIndex..<index(currentIndex, offsetBy: 2)])
            
            let scanner = Scanner(string: substring)
            
            var result: UInt32 = 0
            let success = scanner.scanHexInt32(&result)
            if success {
                let byteResult: UInt8 = UInt8(result)
                data.append([byteResult], length: 1)
            } else {
                DebugManager.log("String could not be parsed as hex: \(self)")
                return nil
            }
            
            currentIndex = index(currentIndex, offsetBy: 2)
        }
        
        return data as Data
    }
}
