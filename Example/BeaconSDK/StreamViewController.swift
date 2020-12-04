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

        beaconStringObserver = NotificationObserver(notification: beaconStringNotification, queue: OperationQueue.main) {
            [weak self] (string) in
            self?.displayString(string)
        }
    }

    private func displayString(_ string: String) {
        let text = textView.text ?? ""
        textView.text = "\(text)\(string)"
        if textView.text.count > maxTextViewCharacterCount {
            textView.text = String(textView.text.suffix(maxTextViewCharacterCount))
        }
        
        textView.scrollRangeToVisible(NSMakeRange(textView.text.count - 1, 1))
        
    }
}
