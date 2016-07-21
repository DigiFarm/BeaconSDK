//
//  StreamViewController.swift
//  BeaconSDKTestClient
//
//  Created by Paul Himes on 3/9/16.
//  Copyright © 2016 Glacial Ridge Technologies. All rights reserved.
//

import UIKit

class StreamViewController: UIViewController {

    private var beaconStringObserver: NotificationObserver?
    private let maxTextViewCharacterCount = 3000
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        beaconStringObserver = NotificationObserver(notification: beaconStringNotification, queue: NSOperationQueue.mainQueue()) {
            [weak self] (string) in
            self?.displayString(string)
        }
    }

    private func displayString(string: String) {
        let text = textView.text ?? ""
        textView.text = "\(text)\(string)"
        if textView.text.characters.count > maxTextViewCharacterCount {
            textView.text = textView.text.substringFromIndex(textView.text.characters.endIndex.advancedBy(-maxTextViewCharacterCount))
        }
        
        textView.scrollRangeToVisible(NSMakeRange(textView.text.characters.count - 1, 1))
        
    }
}
