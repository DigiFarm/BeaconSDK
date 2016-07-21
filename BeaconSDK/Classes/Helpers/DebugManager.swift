//
//  DebugManager.swift
//  ntrip
//
//  Created by Paul Himes on 9/27/14.
//  Copyright (c) 2014 Rolling Forks Design Group, LLC. All rights reserved.
//

import UIKit

class DebugManager: NSObject {
   
    class func log(message: String) {
        // Core Data
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        Event.createWithMessage(message, inContext: appDelegate.managedObjectContext!)
        
        // Bluetooth
//        EAConnectionManager.sharedManager().debugBroadcastToAllConnections(message, timestamp: NSDate())

        NSLog("%@", message)
        #if DEBUG
        #endif
    }
}
