# BeaconSDK

<!--- [![CI Status](http://img.shields.io/travis/Paul Himes/BeaconSDK.svg?style=flat)](https://travis-ci.org/Paul Himes/BeaconSDK) --->
[![Version](https://img.shields.io/cocoapods/v/BeaconSDK.svg?style=flat)](http://cocoapods.org/pods/BeaconSDK)
[![License](https://img.shields.io/cocoapods/l/BeaconSDK.svg?style=flat)](http://cocoapods.org/pods/BeaconSDK)
[![Platform](https://img.shields.io/cocoapods/p/BeaconSDK.svg?style=flat)](http://cocoapods.org/pods/BeaconSDK)

The DigiFarm NTRIP Client app is used to deliver RTK corrections data to the GRTech Beacon V3.0 family of devices. This SDK allows your iOS app to receive NMEA data from the Beacon through the DigiFarm Client app.

## Requirements

* iOS 9+

## How to Receive NMEA data using the Beacon SDK

1. Install the DigiFarm NTRIP Client app.
2. Pair your iOS device with a GRTech Beacon V3.0 connected to a compatable GPS receiver.
3. Login to an appropriate NTRIP server and start streaming data.
4. Launch your app which integrates the Beacon SDK

## Installation

BeaconSDK is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "BeaconSDK"
```

## Usage

```Swift
import BeaconSDK

class MyClass: BeaconReceiverDelegate {

    let receiver = BeaconReceiver()

    func beginReceiving() {
        receiver.delegate = self
        receiver.start()
    }

    func receiver(receiver: BeaconReceiver, parsedString string: String) {
        // Handle raw NMEA string data here.
    }

    func receiver(receiver: BeaconReceiver, parsedGGA gga: GGA) {
        // Handle a parsed GGA sentence struct here.
    }

    func receiver(receiver: BeaconReceiver, parsedVTG vtg: VTG) {
        // Handle a parsed VTG sentence struct here.
    }

    func receiver(receiver: BeaconReceiver, parsedGSV gsv: GSV) {
        // Handle a parsed GSV sentence struct here.
    }

}
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Author

Paul Himes, digifarm@tinwhistlellc.com

## License

BeaconSDK is available under the Apache 2.0 license. See the LICENSE file for more info.
