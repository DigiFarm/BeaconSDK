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
    
    fileprivate var serviceFetcher = BeaconServiceFetcher()
    fileprivate var services: [NetService] = []
    fileprivate var socket: GCDAsyncSocket?
    fileprivate var rawStringBuffer = Data()
    fileprivate var nmeaBuffer = Data()
    fileprivate let nmeaParser = NMEAParser()
    
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
        rawStringBuffer = Data()
        nmeaBuffer = Data()
    }
    
    fileprivate func connectToService(_ service: NetService) {
        if let addresses = service.addresses {
            for address in addresses {
                DebugManager.log("Attempting to connect to \(address)")
                socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
                
                do {
                    try socket?.connect(toAddress: address)
                    break
                } catch let error as NSError {
                    DebugManager.log("Failed to connect to address(\(address)): \(error)")
                }
            }
        }
    }
    
    func socket(_ sock: GCDAsyncSocket!, didConnectToHost host: String!, port: UInt16) {
        DebugManager.log("Socket connected to host(\(host)) port(\(port))")
        sock.readData(withTimeout: -1, tag: -1)
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket!, withError err: NSError!) {
        DebugManager.log("Socket disconnected: \(err)")
        start()
    }
    
    func socket(_ sock: GCDAsyncSocket!, didRead data: Data!, withTag tag: Int) {
        //        DebugManager.log("Socket read data")
        
        let combinedRawStringData = rawStringBuffer.dataByAppendingData(data)
        if let rawString = combinedRawStringData.toString() {
            delegate?.streamer(self, parsedString: rawString)
            rawStringBuffer = Data()
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
            
            nmeaBuffer = remainder.toData() ?? Data()
        }
        
        sock.readData(withTimeout: -1, tag: -1)
    }
}

protocol BeaconServiceStreamerDelegate {
    
    func streamer(_ streamer: BeaconServiceStreamer, parsedString string: String)
    func streamer(_ streamer: BeaconServiceStreamer, parsedGGA gga: GGA)
    func streamer(_ streamer: BeaconServiceStreamer, parsedVTG vtg: VTG)
    func streamer(_ streamer: BeaconServiceStreamer, parsedGSV gsv: GSV)
    
}

extension BeaconReceiver: BeaconServiceStreamerDelegate
{
    func streamer(_ streamer: BeaconServiceStreamer, parsedString string: String) {
        delegate?.receiver?(self, parsedString: string)
    }
    
    func streamer(_ streamer: BeaconServiceStreamer, parsedGGA gga: GGA) {
        delegate?.receiver?(self, parsedGGA: gga)
    }
    
    func streamer(_ streamer: BeaconServiceStreamer, parsedVTG vtg: VTG) {
        delegate?.receiver?(self, parsedVTG: vtg)
    }
    
    func streamer(_ streamer: BeaconServiceStreamer, parsedGSV gsv: GSV) {
        delegate?.receiver?(self, parsedGSV: gsv)
    }
}
