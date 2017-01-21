//
//  StreamViewController.swift
//  BeaconSDKTestClient
//
//  Created by Paul Himes on 3/9/16.
//  Copyright © 2016 Glacial Ridge Technologies. All rights reserved.
//

import UIKit

class StreamViewController: UIViewController {

    fileprivate var beaconStringObserver: NotificationObserver?
    fileprivate let maxTextViewCharacterCount = 3000
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        beaconStringObserver = NotificationObserver(notification: beaconStringNotification, queue: OperationQueue.main) {
            [weak self] (string) in
            self?.displayString(string)
        }
    }

    fileprivate func displayString(_ string: String) {
        let text = textView.text ?? ""
        textView.text = "\(text)\(string)"
        if textView.text.characters.count > maxTextViewCharacterCount {
            textView.text = textView.text.substring(from: textView.text.characters.index(textView.text.characters.endIndex, offsetBy: -maxTextViewCharacterCount))
        }
        
        textView.scrollRangeToVisible(NSMakeRange(textView.text.characters.count - 1, 1))
        
    }
}
