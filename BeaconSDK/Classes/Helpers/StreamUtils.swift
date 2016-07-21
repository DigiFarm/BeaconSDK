//
//  StreamUtils.swift
//  ntrip
//
//  Created by Paul Himes on 2/21/15.
//  Copyright (c) 2015 Rolling Forks Design Group, LLC. All rights reserved.
//

import Foundation

let MB = 1048576

extension NSStream {
    var statusString: String {
        get {
            switch streamStatus {
            case .NotOpen:
                return "Not Open"
            case .Opening:
                return "Opening"
            case .Open:
                return "Open"
            case .Reading:
                return "Reading"
            case .Writing:
                return "Writing"
            case .AtEnd:
                return "At End"
            case .Closed:
                return "Closed"
            case .Error:
                return "Error"
            }
        }
    }
}

extension NSData {
    func hexString() -> NSString {
        let str = NSMutableString()
        let bytes = UnsafeBufferPointer<UInt8>(start: UnsafePointer(self.bytes), count:self.length)
        for byte in bytes {
            str.appendFormat("%02hhx", byte)
        }
        return str
    }
    
    func dataByAppendingData(data: NSData, fifoLimit: Int = 0) -> NSData {
        let combinedBuffer = NSMutableData(data: self)
        combinedBuffer.appendData(data)
        
        if fifoLimit > 0 && combinedBuffer.length > fifoLimit {
            
            DebugManager.log("Error: Buffer Overflow")
            
            return combinedBuffer.subdataWithRange(NSMakeRange(combinedBuffer.length - fifoLimit, fifoLimit))
        }
        
        return NSData(data: combinedBuffer)
    }
    
    func dataByAppendingBytes(bytes: UnsafePointer<Void>, length: Int, fifoLimit: Int = 0) -> NSData {
        let combinedBuffer = NSMutableData(data: self)
        combinedBuffer.appendBytes(bytes, length: length)
        
        if fifoLimit > 0 && combinedBuffer.length > fifoLimit {
            return combinedBuffer.subdataWithRange(NSMakeRange(combinedBuffer.length - fifoLimit, fifoLimit))
        }
        
        return NSData(data: combinedBuffer)
    }
    
    func componentsSeparatedByData(data: NSData) -> [NSData] {

        var components = [NSData]()
    
        var searchRangeLocation = 0
        
        while searchRangeLocation < length {
            let searchRange = NSMakeRange(searchRangeLocation, length - searchRangeLocation)
            let separatorRange = rangeOfData(data, options: [], range: searchRange)
            if separatorRange.location != NSNotFound {
                let componentRange = NSMakeRange(searchRangeLocation, separatorRange.location - searchRangeLocation)
                components.append(subdataWithRange(componentRange))
                searchRangeLocation = separatorRange.location + separatorRange.length
            } else {
                components.append(subdataWithRange(searchRange))
                break
            }
        }
        
        return components
    }
    
    func endsWithData(data: NSData) -> Bool {
        if data.length > length {
            return false
        }
        
        let range = rangeOfData(data, options: [], range: NSMakeRange(length - data.length, data.length))
        return range.location != NSNotFound
    }
    
    func endsWithHex(hex: String) -> Bool {
        return endsWithData(hex.dataFromHexString()!)
    }
    
    func toString() -> String? {
        return NSString(data: self, encoding: NSUTF8StringEncoding) as? String
    }
}

extension String {
    func toData() -> NSData? {
        return dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
    }
    
    func dataFromHexString() -> NSData? {

        let data = NSMutableData()
        
        var currentIndex = self.startIndex
        while currentIndex < self.endIndex.advancedBy(-1) {
            let substring = self.substringWithRange(currentIndex..<currentIndex.advancedBy(2))
            
            let scanner = NSScanner(string: substring)
            
            var result: UInt32 = 0
            let success = scanner.scanHexInt(&result)
            if success {
                let byteResult: UInt8 = UInt8(result)
                data.appendBytes([byteResult], length: 1)
            } else {
                DebugManager.log("String could not be parsed as hex: \(self)")
                return nil
            }
            
            currentIndex = currentIndex.advancedBy(2)
        }
        
        return data
    }
}