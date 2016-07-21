//
//  BeaconServiceStreamer.swift
//  NetworkTestClient
//
//  Created by Paul Himes on 3/7/16.
//  Copyright © 2016 Paul Himes. All rights reserved.
//

import UIKit

class BeaconServiceStreamer: NSObject, GCDAsyncSocketDelegate {

    var delegate: BeaconServiceStreamerDelegate?
    
    private var serviceFetcher = BeaconServiceFetcher()
    private var services: [NSNetService] = []
    private var socket: GCDAsyncSocket?
    private var rawStringBuffer = NSData()
    private var nmeaBuffer = NSData()
    private let nmeaParser = NMEAParser()
    
    func start() {
        stop()
        
        serviceFetcher.fetchBeaconServicesWithCompletion { [weak self] (service) -> Void in
            guard let strongSelf = self else { return }
            
            DebugManager.log("Streamer received a service callback.")
            
            if !strongSelf.services.contains(service) {
                strongSelf.services.append(service)
            }
            
            if strongSelf.socket == nil {
                strongSelf.connectToService(service)
            }
        }
    }
    
    func stop() {
        serviceFetcher.reset()
        services = []
        socket?.delegate = nil
        socket?.disconnect()
        socket = nil
        rawStringBuffer = NSData()
        nmeaBuffer = NSData()
    }
    
    private func connectToService(service: NSNetService) {
        if let addresses = service.addresses {
            for address in addresses {
                DebugManager.log("Attempting to connect to \(address)")
                socket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
                
                do {
                    try socket?.connectToAddress(address)
                    break
                } catch let error as NSError {
                    DebugManager.log("Failed to connect to address(\(address)): \(error)")
                }
            }
        }
    }
    
    func socket(sock: GCDAsyncSocket!, didConnectToHost host: String!, port: UInt16) {
        DebugManager.log("Socket connected to host(\(host)) port(\(port))")
        sock.readDataWithTimeout(-1, tag: -1)
    }
    
    func socketDidDisconnect(sock: GCDAsyncSocket!, withError err: NSError!) {
        DebugManager.log("Socket disconnected: \(err)")
        start()
    }
    
    func socket(sock: GCDAsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
        //        DebugManager.log("Socket read data")
        
        let combinedRawStringData = rawStringBuffer.dataByAppendingData(data)
        if let rawString = combinedRawStringData.toString() {
            delegate?.streamer(self, parsedString: rawString)
            rawStringBuffer = NSData()
        }
        
        let combinedNMEAData = nmeaBuffer.dataByAppendingData(data)
        if let string = combinedNMEAData.toString() {
            
            let (ggas, vtgs, gsvs, remainder) = NMEAParser.parse(string)
            
            for gga in ggas {
                delegate?.streamer(self, parsedGGA: gga)
            }
            
            for vtg in vtgs {
                delegate?.streamer(self, parsedVTG: vtg)
            }
            
            for gsv in gsvs {
                delegate?.streamer(self, parsedGSV: gsv)
            }
            
            nmeaBuffer = remainder.toData() ?? NSData()
        }
        
        sock.readDataWithTimeout(-1, tag: -1)
    }
}

protocol BeaconServiceStreamerDelegate {
    
    func streamer(streamer: BeaconServiceStreamer, parsedString string: String)
    func streamer(streamer: BeaconServiceStreamer, parsedGGA gga: GGA)
    func streamer(streamer: BeaconServiceStreamer, parsedVTG vtg: VTG)
    func streamer(streamer: BeaconServiceStreamer, parsedGSV gsv: GSV)
    
}

extension BeaconReceiver: BeaconServiceStreamerDelegate
{
    func streamer(streamer: BeaconServiceStreamer, parsedString string: String) {
        delegate?.receiver?(self, parsedString: string)
    }
    
    func streamer(streamer: BeaconServiceStreamer, parsedGGA gga: GGA) {
        delegate?.receiver?(self, parsedGGA: gga)
    }
    
    func streamer(streamer: BeaconServiceStreamer, parsedVTG vtg: VTG) {
        delegate?.receiver?(self, parsedVTG: vtg)
    }
    
    func streamer(streamer: BeaconServiceStreamer, parsedGSV gsv: GSV) {
        delegate?.receiver?(self, parsedGSV: gsv)
    }
}