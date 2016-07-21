//
//  BeaconReceiver.swift
//  BeaconSDK
//
//  Created by Paul Himes on 3/16/16.
//  Copyright © 2016 Glacial Ridge Technologies. All rights reserved.
//

import Foundation

/**
 An instance of the `BeaconReceiver` class receives Beacon data over the local network.
*/
public class BeaconReceiver: NSObject {

    public var delegate: BeaconReceiverDelegate?
    
    private let streamer = BeaconServiceStreamer()
    
    /**
     Begin receiving Beacon data and passing it on to the delegate.
    */
    public func start() {
        streamer.delegate = self
        streamer.start()
    }
    
    /**
     Stop receiving Beacon data.
     */
    public func stop() {
        streamer.delegate = nil
        streamer.stop()
    }
}

/**
 Implement this protocol to receive Beacon data from a `BeaconReceiver` object.
*/
@objc public protocol BeaconReceiverDelegate {
    
    /**
     Receive raw string data from the Beacon device.
     
     - Parameter receiver: The `BeaconReceiver` which originally received the data
     - Parameter parsedString: The `String` data received by the `BeaconReceiver`
    */
    optional func receiver(receiver: BeaconReceiver, parsedString string: String)
    
    /**
     Receive parsed GGA sentence data from the Beacon device.
     
     - Parameter receiver: The `BeaconReceiver` which originally received the data
     - Parameter parsedGGA: A `GGA` data structure which represents a NMEA GGA sentence contained in the data received by the `BeaconReceiver`
    */
    optional func receiver(receiver: BeaconReceiver, parsedGGA gga: GGA)
    
    /**
     Receive parsed VTG sentence data from the Beacon device.
     
     - Parameter receiver: The `BeaconReceiver` which originally received the data
     - Parameter parsedVTG: A `VTG` data structure which represents a NMEA VTG sentence contained in the data received by the `BeaconReceiver`
    */
    optional func receiver(receiver: BeaconReceiver, parsedVTG vtg: VTG)
    
    /**
     Receive parsed GSV sentence data from the Beacon device.
     
     - Parameter receiver: The `BeaconReceiver` which originally received the data
     - Parameter parsedGSV: A `GSV` data structure which represents a NMEA GSV sentence contained in the data received by the `BeaconReceiver`
     */
    optional func receiver(receiver: BeaconReceiver, parsedGSV gsv: GSV)
}