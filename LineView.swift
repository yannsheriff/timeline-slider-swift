//
//  LineView.swift
//  TimeLine
//
//  Created by Yann Cherif on 15/02/2018.
//  Copyright © 2018 CHERIF Yannis. All rights reserved.
//

import UIKit

class LineView: UIView {

    var fillColor = UIColor(red:0.02, green:0.68, blue:0.97, alpha:1.0)
    var isScrollable = true
    
    override func draw(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.setFillColor(fillColor.cgColor)
        ctx?.setShadow(offset: CGSize(width: 0, height: 0), blur: 3, color: fillColor.cgColor)
        ctx?.addRect(CGRect(origin: CGPoint(x: 0, y: 5), size: CGSize(width: rect.size.width, height:  rect.size.height - 10)))
        ctx?.fillPath()
    }

}
