//
//  SkyplotView.swift
//  BeaconSDKTestClient
//
//  Created by Paul Himes on 5/24/16.
//  Copyright © 2016 Glacial Ridge Technologies. All rights reserved.
//

import UIKit

class SkyplotMarker {
    let label: String
    let azimuth: Double
    let elevation: Double
    private var view: SkyplotView.SkyplotMarkerView?
    
    init(label: String, azimuth: Double, elevation: Double) {
        self.label = label
        self.azimuth = azimuth
        self.elevation = elevation
        self.view = nil
    }
}

@IBDesignable class SkyplotView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(textSizeChanged(_:)), name: UIContentSizeCategoryDidChangeNotification, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(textSizeChanged(_:)), name: UIContentSizeCategoryDidChangeNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIContentSizeCategoryDidChangeNotification, object: nil)
    }

    @objc func textSizeChanged(notification: NSNotification) {
        setNeedsDisplay()
        setNeedsLayout()
    }

    var markers = [SkyplotMarker]() {
        didSet {
            let oldMarkers = oldValue
            print("\(oldMarkers.count) old markers")
            print("\(markers.count) new markers")
            
            
            var markersAdded = [SkyplotMarker]()
            
            for marker in markers {
                let center = CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2)
                let centerOffset = centerOffsetForAzimuth(marker.azimuth, elevation: marker.elevation)
                
                if let oldMarker = (oldMarkers.filter{ $0.label == marker.label }).first {
                    // Marker already exists. Move the marker.
                    if let view = oldMarker.view {
                        marker.view = view
                        
                        let centerXConstraint = view.centerXConstraint!
                        let centerYConstraint = view.centerYConstraint!
                        
                        centerXConstraint.constant = centerOffset.x
                        centerYConstraint.constant = centerOffset.y
                        
                    }
                } else {
                    // Marker is new. Add the marker.
                    let view = SkyplotMarkerView()
                    view.frame = CGRect(x: center.x + centerOffset.x - view.intrinsicContentSize().width / 2, y: center.y + centerOffset.y - view.intrinsicContentSize().height / 2, width: view.intrinsicContentSize().width, height: view.intrinsicContentSize().height)
                    view.translatesAutoresizingMaskIntoConstraints = false
                    view.contentMode = .Redraw
                    view.opaque = false
                    view.string = marker.label
                    addSubview(view)
                    view.alpha = 0
                    marker.view = view

                    let centerXConstraint = NSLayoutConstraint(item: view, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: centerOffset.x)
                    view.centerXConstraint = centerXConstraint
                    
                    let centerYConstraint = NSLayoutConstraint(item: view, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: centerOffset.y)
                    view.centerYConstraint = centerYConstraint
                    //
                    addConstraint(centerXConstraint)
                    addConstraint(centerYConstraint)
                    
                    markersAdded.append(marker)
                }
            }
            
            var markersToRemove = [SkyplotMarker]()
            
            for oldMarker in oldMarkers {
                guard (markers.filter{ $0.label == oldMarker.label }).count == 0 else { continue }
                markersToRemove.append(oldMarker)
            }
            
            UIView.animateWithDuration(1, animations: { [weak self] in
                for marker in markersAdded {
                    marker.view?.alpha = 1
                }
                self?.layoutIfNeeded()
                for marker in markersToRemove {
                    marker.view?.alpha = 0
                }
            }) { (completed) in
                for marker in markersToRemove {
                    marker.view?.removeFromSuperview()
                }
            }
        }
    }
    
    private var labelFont: UIFont {
        get {
            return UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        }
    }
    
    private var textGutterWidth: CGFloat {
        get {
            let letterString = NSAttributedString(string: "W", attributes: [NSFontAttributeName: labelFont])
            return (max(letterString.size().width, letterString.size().height) * 3)
        }
    }
    
    private var elevation0Diameter: CGFloat {
        get {
            let outerDiameter = min(bounds.size.width, bounds.size.height)
            return outerDiameter - 2 * textGutterWidth
        }
    }
    
    private var elevation0Radius: CGFloat {
        get {
            return elevation0Diameter / 2
        }
    }
    
    private let lineColor = UIColor.grayColor()
    
    override func drawRect(rect: CGRect) {
        lineColor.set()
        
        // Draw minor azimuth lines.
        func diameterLineForAngle(angle: Double, radius: CGFloat) -> UIBezierPath {
            let startPoint = azimuthPointForAngle(angle, radius: radius)
            let endPoint = azimuthPointForAngle(angle + 180, radius: radius)
            
            let path = UIBezierPath()
            path.moveToPoint(startPoint)
            path.addLineToPoint(endPoint)
            
            return path
        }
        for i in 0..<18 {
            let diameterPath = diameterLineForAngle(0 + 10 * Double(i), radius: elevation0Radius)
            diameterPath.lineWidth = 2
            diameterPath.stroke()
        }
        // Draw major azimuth lines.
        for i in 0..<6 {
            let diameterPath = diameterLineForAngle(0 + 30 * Double(i), radius: elevation0Radius + (i % 3 == 0 ? textGutterWidth * 0.3 : 0))
            diameterPath.lineWidth = i % 3 == 0 ? 6 : 4
            diameterPath.stroke()
        }
        
        // Draw elevation circles.
        let elevationLineCount = 9
        for i in 0..<elevationLineCount {
            let elevationDiameter = elevation0Diameter * (CGFloat(elevationLineCount - i)) / CGFloat(elevationLineCount)
            
            // Center the circle in the bounds.
            let elevationCirclePath = UIBezierPath(ovalInRect: CGRect(x: (bounds.size.width - elevationDiameter) / 2, y: (bounds.size.height - elevationDiameter) / 2, width: elevationDiameter, height: elevationDiameter))
            
            // Fade at a rounded rate.
            let degree = 90 * Double(i) / Double(elevationLineCount)
            let radian = degree / 180 * M_PI
            let invertedAlpha = sin(radian)
            
            lineColor.colorWithAlphaComponent(1 - 0.8 * CGFloat(invertedAlpha)).set()
            
            elevationCirclePath.lineWidth = 2
            elevationCirclePath.stroke()
        }
        
        // Draw cardinal direction letters.
        func drawLabel(string: String, atDegree degree: Double) {
            let letterString = NSAttributedString(string: string, attributes: [NSFontAttributeName: labelFont, NSForegroundColorAttributeName: lineColor])
            let letterCenter = azimuthPointForAngle(degree, radius: elevation0Radius + textGutterWidth / 2)
            let size = letterString.size()
            letterString.drawAtPoint(CGPoint(x: letterCenter.x - size.width / 2, y: letterCenter.y - size.height / 2))
        }
        drawLabel("N", atDegree: 0)
        drawLabel("E", atDegree: 90)
        drawLabel("S", atDegree: 180)
        drawLabel("W", atDegree: 270)
    }
    
    private func azimuthPointForAngle(angle: Double, radius: CGFloat) -> CGPoint {
        let center = CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2)
        
        let radians = angle / 180 * M_PI
        
        // sine is positive x
        let xOffset = Double(radius) * sin(radians)
        // cosine is negative y
        let yOffset = Double(radius) * -cos(radians)
        
        return CGPoint(x: Double(center.x) + xOffset, y: Double(center.y) + yOffset)
    }
    
    private func centerOffsetForAzimuth(azimuth: Double, elevation: Double) -> CGPoint {
        let limitedElevation = min(90, max(0, elevation))
        let radius = elevation0Radius * (1 - CGFloat(limitedElevation) / 90)
        let point = azimuthPointForAngle(azimuth, radius: radius)
        
        let center = CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2)
        
        let offset = CGPoint(x: point.x - center.x, y: point.y - center.y)
        
        return offset
    }
    
    private class SkyplotMarkerView: UIView {
        
        private var centerXConstraint: NSLayoutConstraint?
        private var centerYConstraint: NSLayoutConstraint?
        private var string: String?
        
        private var markerFont: UIFont {
            get {
                return UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
            }
        }
        
        private var markerWidth: CGFloat {
            get {
                let letterString = NSAttributedString(string: "88", attributes: [NSFontAttributeName: markerFont])
                return max(letterString.size().width, letterString.size().height) * 1.50
            }
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(textSizeChanged(_:)), name: UIContentSizeCategoryDidChangeNotification, object: nil)
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(textSizeChanged(_:)), name: UIContentSizeCategoryDidChangeNotification, object: nil)
        }
        
        deinit {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: UIContentSizeCategoryDidChangeNotification, object: nil)
        }
        
        @objc func textSizeChanged(notification: NSNotification) {
            invalidateIntrinsicContentSize()
            setNeedsDisplay()
            setNeedsLayout()
        }
        
        override func drawRect(rect: CGRect) {
            UIBezierPath(ovalInRect: bounds).addClip()
            tintColor.set()
            UIBezierPath(rect: bounds).fill()
            
            if let string = string {
                let attributedString = NSAttributedString(string: string, attributes: [NSFontAttributeName: markerFont, NSForegroundColorAttributeName: UIColor.whiteColor()])
                let stringSize = attributedString.size()
                let anchorPoint = CGPoint(x: (bounds.size.width - stringSize.width) / 2, y: (bounds.size.height - stringSize.height) / 2)
                attributedString.drawAtPoint(anchorPoint)
            }
        }
        
        private override func intrinsicContentSize() -> CGSize {
            return CGSize(width: markerWidth, height: markerWidth)
        }
    }
}