//
//  TimeLineController.swift
//  TimeLine
//
//  Created by CHERIF Yannis on 13/02/2018.
//  Copyright © 2018 CHERIF Yannis. All rights reserved.
//

import UIKit

protocol TimeLineControlDelegate: class {
    
    /**
     Function Triggered When the user is actualy dragging one of the thumbs.
     
     - returns: an array with both values [firstThumb, secondThumb]
     */
    func userIsDragging(_ values: Array<CGFloat>)
    
    /**
     Function Triggered when the user stop dragging and remove he's finger.
     
     - returns: an array with both values [firstThumb, secondThumb]
     */
    func userDidEndDrag(_ values: Array<CGFloat>)
    
    /**
     Function Triggered when the user add a step to the timeLine.
     
     - returns: return the value of the new step
     */
    func userAddedStep(_ value: Int)
    
    /**
     Function Triggered when the user remove a step from the timeLine.
     
     - returns: return the value of the new step
     */
    func userRemovedStep(_ value: Int)
}

class TimeLineControl: UIView, UIGestureRecognizerDelegate {
    
    
/*  ==========================================================
    == Global variables  ==
    ======================================================= */
    
    private         let verticalPosition    : CGFloat = 10
    private         let circleRadius        : CGFloat = 8
    private         var draggableZoneWidth  : CGFloat!
    private         var firstCircle         : CircleView?
    private         var secondCircle        : CircleView?
    private         var line                : LineView?
    @IBInspectable  var firstValue          : CGFloat = 50
    @IBInspectable  var secondValue         : CGFloat = 100
    @IBInspectable  var thumbSize         : CGFloat = 32
    @IBInspectable  var timelineMode        : Bool = false
    @IBInspectable  var timelineSteps       : Int = 5
    @IBInspectable  var timelineInitSteps   : Int = 1
    @IBInspectable  var LineColor           : UIColor = UIColor.black
    private         var viewDidInit         : Bool = false
    private         var circles             : Array<CircleView>     = []
    weak            var delegate            : TimeLineControlDelegate?
    private         var intervalBetweenCircles:CGFloat = 0
    
    
    
    
    
    
    
/*  ==========================================================
    == Drawing Part  ==
    ======================================================= */
    
    override func draw(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        let width  = rect.size.width - circleRadius * 4 - 2
        
        // if TimeLine mode is Ativated :
        
        if timelineMode {
            intervalBetweenCircles = (width - ( CGFloat(timelineSteps) * (2*circleRadius)))/CGFloat(timelineSteps) - 1
            
            for i in 0..<timelineSteps + 1 {
                let strokes     = (CGFloat(i) * intervalBetweenCircles)
                let circles     = (CGFloat(i) * (circleRadius*2)) + (circleRadius*2) + 1
                let startStroke = strokes + circles
                ctx?.setStrokeColor(LineColor.cgColor)
                ctx?.addEllipse(
                    in: CGRect(
                        origin: CGPoint(
                            x: startStroke - (circleRadius*2),
                            y: verticalPosition),
                        size:   CGSize(
                            width: circleRadius * 2,
                            height: circleRadius * 2)
                ))
                
                if (i != timelineSteps) {
                    ctx?.move(
                        to: CGPoint(
                            x: startStroke,
                            y: verticalPosition + circleRadius
                    ))
                    ctx?.addLine(
                        to: CGPoint(
                            x: startStroke + intervalBetweenCircles,
                            y: verticalPosition + circleRadius
                    ))
                }
            }
        }
        
        // if TimeLine mode isn't Ativated :
        
        if !timelineMode {
            ctx?.addEllipse(
                in: CGRect(
                    origin: CGPoint(
                        x: 1 ,
                        y: verticalPosition),
                    size: CGSize(
                        width: circleRadius * 2,
                        height: circleRadius * 2)
            ))
            
            ctx?.move(
                to: CGPoint(
                    x: circleRadius * 2,
                    y: verticalPosition + circleRadius
            ))
            
            ctx?.addLine(
                to: CGPoint(
                    x: rect.size.width - circleRadius * 2,
                    y: verticalPosition + circleRadius
            ))
            
            ctx?.addEllipse(
                in: CGRect(
                    origin: CGPoint(
                        x:rect.size.width - circleRadius * 2 - 1 ,
                        y: 10),
                    size: CGSize(
                        width: circleRadius * 2,
                        height: circleRadius * 2)
            ))
        }
        
        // Stroke the line :
        
        ctx?.strokePath()
    }
    
    
    
    
    
    
    
/* ==========================================================
   == Initialisation  ==
   ======================================================= */
    
    override func awakeFromNib() {
        draggableZoneWidth = self.bounds.size.width-thumbSize-2
        if (!timelineMode) {
            
            /*
            *   Init left Draggable Circle
            */
            let firstCirclePostion = calcXposition(percent: 0).left
            firstCircle = CircleView(
                frame: CGRect(
                    x: calcXBoundPosition(center: firstCirclePostion).left,
                    y: 18-thumbSize/2,
                    width: thumbSize,
                    height: thumbSize
            ))
            firstCircle?.backgroundColor = UIColor.clear
            firstCircle?.fillColor = tintColor
            self.addSubview(firstCircle!)
            let gestureForFirstValue = UIPanGestureRecognizer(target: self, action: #selector(handleDrag))
            gestureForFirstValue.delegate = self as UIGestureRecognizerDelegate
            firstCircle!.addGestureRecognizer(gestureForFirstValue)
            
            /*
             *   Init Right Draggable Circle
             */
            let secondCirclePostion = calcXposition(percent: 100).right
            secondCircle = CircleView(
                frame: CGRect(
                    x:calcXBoundPosition(center: secondCirclePostion).right ,
                    y: 18-thumbSize/2,
                    width: thumbSize,
                    height: thumbSize
            ))
            secondCircle?.backgroundColor = UIColor.clear
            secondCircle?.fillColor = tintColor
            self.addSubview(secondCircle!)
            let gestureForSecondValue = UIPanGestureRecognizer(target: self, action: #selector(handleDrag))
            gestureForSecondValue.delegate = self as UIGestureRecognizerDelegate
            secondCircle!.addGestureRecognizer(gestureForSecondValue)
        }
        
        
        /*
         *   Initialise Swip Gesture Reconizer
         */
        if (timelineMode) {
            let swipRightGestureReconizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipRight))
            swipRightGestureReconizer.direction = UISwipeGestureRecognizerDirection.right
            swipRightGestureReconizer.delegate = self as UIGestureRecognizerDelegate
            self.addGestureRecognizer(swipRightGestureReconizer)
            
            let swipLeftGestureReconizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipLeft))
            swipLeftGestureReconizer.direction = UISwipeGestureRecognizerDirection.left
            swipLeftGestureReconizer.delegate = self as UIGestureRecognizerDelegate
            self.addGestureRecognizer(swipLeftGestureReconizer)
        }
    }
    
    
    /*
     *   Initialise line & scale
     */
    override func layoutSubviews() {
        if (!viewDidInit) {
            draggableZoneWidth = self.bounds.size.width-thumbSize-2
            drawInitialLine()
            if !timelineMode {
               changeValues(first: firstValue, second: secondValue)
            }
            viewDidInit = !viewDidInit
        }
    }
    
    
    
    
    
    
    
/*  ==========================================================
    == Gesture Reconizer  ==
    ======================================================= */
    
    /*
     *   Drag Gestion
     */
    @objc func handleDrag(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self)
        if let view = recognizer.view {
            
            //gestion pour le premier cercle
            if (view == firstCircle && firstCircle!.isScrollable) {
                if (firstValue < secondValue - 10) {
                    drag(circle: view, to: translation.x, value: "firstValue")
                    moveLineToCenter(animated: false)
                    changeLineSize(animated: false)
                }
                if (firstValue > secondValue - 10) {
                    firstCircle!.isScrollable = false
                    firstValue = secondValue - 10.1
                    let destination = calcXposition(percent: firstValue).left
                    move(point: view, to: destination)
                    moveLineToCenter(animated: false)
                    changeLineSize(animated: false)
                    
                }
                if (firstValue < 0) {
                    firstCircle!.isScrollable = false
                    firstValue = 0
                    let destination = calcXposition(percent: firstValue).left
                    move(point: view, to: destination)
                    moveLineToCenter(animated: false)
                    changeLineSize(animated: false)
                }
                delegate?.userIsDragging([firstValue, secondValue])
            }
            
            //gestion pour le deuxieme cercle
            if (view == secondCircle && secondCircle!.isScrollable) {
                if (secondValue > firstValue + 10) {
                    drag(circle: view, to: translation.x, value: "secondValue")
                    moveLineToCenter(animated: false)
                    changeLineSize(animated: false)
                }
                if (secondValue < firstValue + 10) {
                    secondCircle!.isScrollable = false
                    secondValue = firstValue + 10.1
                    let destination = calcXposition(percent: secondValue).right
                    move(point: view, to: destination)
                    moveLineToCenter(animated: false)
                    changeLineSize(animated: false)
                }
                
                if (secondValue > 100) {
                    secondCircle!.isScrollable = false
                    secondValue = 100
                    let destination = calcXposition(percent: secondValue).right
                    move(point: view, to: destination)
                    moveLineToCenter(animated: false)
                    changeLineSize(animated: false)
                }
                delegate?.userIsDragging([firstValue, secondValue])
            }
            
            // lors du relachement
            if(recognizer.state.rawValue == 3) {
                firstCircle!.isScrollable = true
                secondCircle!.isScrollable = true
                delegate?.userDidEndDrag([firstValue, secondValue])
            }
        }
        
        recognizer.setTranslation(CGPoint.zero, in: self)
    }
    
    /*
     *   Swip Right
     */
    @objc func handleSwipRight(recognizer: UISwipeGestureRecognizer) {
        self.addStep()
        delegate?.userAddedStep(circles.count)
    }
    
    /*
     *   Swip Left
     */
    @objc func handleSwipLeft(recognizer: UISwipeGestureRecognizer) {
        self.removeStep()
        delegate?.userRemovedStep(circles.count)
    }
    
    
    
    
    
    
/*  ==========================================================
    == Public Functions  ==
    ======================================================= */
    
    /**
     Move the first thumb of your slider to the position.
     
     @param CGFLoat from 0 to 100
     */
    public func changeFirstValue(to: CGFloat) {
        if !timelineMode {
            firstValue = to
            let destination = calcXposition(percent: firstValue).left
            move(point: firstCircle!, to: destination)
            moveLineToCenter(animated: true)
            changeLineSize(animated: true)
        }
    }
    
    
    /**
     Move the Second thumb of your slider to the position.
     
     - parameter to: CGFLoat from 0 to 100
     */
    public func changeSecondValue(to: CGFloat) {
        if !timelineMode {
            secondValue = to
            let destination = calcXposition(percent: secondValue).right
            move(point: secondCircle!, to: destination)
            moveLineToCenter(animated: true)
            changeLineSize(animated: true)
        }
    }
    
    
    /**
     Move the both thumb of your slider to the position.
     
     - parameter first: value of first thumb from 0 to 100
     - parameter second: value of second thumb from 0 to 100
     */
    public func changeValues(first: CGFloat, second: CGFloat) {
        if !timelineMode {
            firstValue = first
            secondValue = second
            let destinationFirst = calcXposition(percent: firstValue).left
            let destinationSecond = calcXposition(percent: secondValue).right
            move(point: firstCircle!, to: destinationFirst)
            move(point: secondCircle!, to: destinationSecond)
            moveLineToCenter(animated: true)
            changeLineSize(animated: true)
        }
    }
    
    /**
     Increment the timeLine By 1
     */
    public func addStep() {
        if timelineMode {
            if circles.count <= timelineSteps {
                let newStep = circles.count + 1
                let width  = self.bounds.width - circleRadius * 4 - 2
                let sumCircle = CGFloat(newStep-2) * (2 * circleRadius)
                let sumDash = CGFloat(newStep-1) * intervalBetweenCircles
                let lineSize = sumCircle + sumDash
                let lineCenter = lineSize/2 + (2 * circleRadius) + 1
                UIView.animate(withDuration: 0.5, animations: {
                    self.line!.bounds.size.width = lineSize
                }, completion: nil)
                UIView.animate(withDuration: 0.5, animations: {
                    self.line?.center = CGPoint(x: lineCenter, y: 18)
                }, completion: nil)
                drawCircles(nbCirclesToDraw: newStep, timelineWidth: width )
            }
        }
    }
    
    /**
     Decrement the timeLine By 1
     */
    public func removeStep() {
        if timelineMode {
            if circles.count > 1 {
                let newStep = circles.count - 1
                let width  = self.bounds.width - circleRadius * 4 - 2
                let sumCircle = CGFloat(newStep-2) * (2 * circleRadius)
                let sumDash = CGFloat(newStep-1) * intervalBetweenCircles
                let lineSize = sumCircle + sumDash
                let lineCenter = lineSize/2 + (2 * circleRadius) + 1
                UIView.animate(withDuration: 0.5, animations: {
                    self.line!.bounds.size.width = lineSize
                }, completion: nil)
                UIView.animate(withDuration: 0.5, animations: {
                    self.line?.center = CGPoint(x: lineCenter, y: 18)
                }, completion: nil)
                drawCircles(nbCirclesToDraw: newStep, timelineWidth: width )
            }
        }
    }
    
    
    
    
    
    
    
/*  ==========================================================
    == Helper Functions ==
    ======================================================= */
    
    /*
     *   Init Line
     */
    private func drawInitialLine() {
        if timelineMode {
            if (timelineInitSteps <= timelineSteps) {
                timelineSteps = timelineSteps - 1
                let width  = self.bounds.width - circleRadius * 4 - 2
                let intervalBetweenCircles = (width - ( CGFloat(timelineSteps) * (2*circleRadius)))/CGFloat(timelineSteps) - 1
                let x = CGFloat(timelineInitSteps == 0 ? 0 : timelineInitSteps - 1)
                let lineSizeforInit = (x-1) * (2 * circleRadius) + x * intervalBetweenCircles
                line = LineView(frame: CGRect(x: 1 + 2*circleRadius , y: 12, width: lineSizeforInit, height: 13))
                line?.backgroundColor = UIColor.clear
                line?.fillColor = tintColor
                drawCircles(nbCirclesToDraw: timelineInitSteps, timelineWidth: intervalBetweenCircles )
            }
        } else {
            line = LineView(frame: CGRect(x: calcStartLine(percent: firstValue) , y: 12, width: calculateLineSize(), height: 13))
            line?.backgroundColor = UIColor.clear
            line?.fillColor = tintColor
        }
        self.addSubview(line!)
    }
    
    private func drawCircles(nbCirclesToDraw : Int, timelineWidth: CGFloat) {
        var drawedCircles = circles.count
        intervalBetweenCircles = (timelineWidth - ( CGFloat(timelineSteps) * (2*circleRadius)))/CGFloat(timelineSteps) - 1
        if drawedCircles != 0 {
            let circleLeftToDraw =  nbCirclesToDraw - circles.count
            if circleLeftToDraw > 0 {
                var i : Int = 0
                repeat {
                    drawedCircles = circles.count
                    let sumCircles = CGFloat(drawedCircles) * (2*circleRadius)
                    let sumInterval = CGFloat(drawedCircles) * intervalBetweenCircles
                    let pos = sumCircles + sumInterval - 5
                    createCircleWithAnimation(x: pos, y: 18-thumbSize/2)
                    
                    i = i + 1
                } while i < circleLeftToDraw
            }
            if circleLeftToDraw < 0 {
                var i : Int = circleLeftToDraw
                repeat {
                    let tableIndex = circles.count-1
                    circles[tableIndex].removeFromSuperview()
                    circles.remove(at: tableIndex)
                    i = i + 1
                } while i < 0
            }
        } else {
            var i : Int = 0
            repeat {
                let circlePostion = drawCircles_calcXposition(index: i, width: timelineWidth)
                let circle = CircleView(frame: CGRect(x: circlePostion, y: 18-thumbSize/2, width: thumbSize, height: thumbSize))
                circle.backgroundColor = UIColor.clear
                circle.fillColor = tintColor
                circles.append(circle)
                self.addSubview(circles.last!)
                i = i + 1
            } while i < nbCirclesToDraw
        }
        
    }
    
    private func drawCircles_calcXposition(index: Int, width: CGFloat) -> CGFloat {
        return ((2*circleRadius + width) * CGFloat(index)) - 5
    }
    
    private func createCircleWithAnimation(x: CGFloat, y: CGFloat) {
        let x = x + self.thumbSize / 2
        let y = y + self.thumbSize / 2
        let circle = CircleView(frame: CGRect(x: x, y: y, width: 0, height: 0))
        circle.backgroundColor = UIColor.clear
        circle.fillColor = tintColor
        self.circles.append(circle)
        self.addSubview(circle)
        UIView.animate(withDuration: 0.6, animations: {
            circle.bounds.size.width = self.thumbSize
            circle.bounds.size.height = self.thumbSize
        }, completion: nil)
    }
    
    private func calcXposition(percent: CGFloat) -> (left: CGFloat, right: CGFloat) {
        let l =  (draggableZoneWidth * percent / 100) + (1  + thumbSize/2) - 5
        let r = (draggableZoneWidth * percent / 100) + (1  + thumbSize/2) + 5
        return (left: l, right: r)
    }
    
    private func calcXBoundPosition (center: CGFloat) -> (left: CGFloat, right: CGFloat) {
        let l = center - (thumbSize / 2)
        let r = center - (thumbSize / 2)
        return (left: l, right: r)
    }
    
    private func calcStartLine (percent: CGFloat) ->  CGFloat {
        return (draggableZoneWidth * percent / 100) + (1 + thumbSize) - 10
    }
    
    
    private func move(point: UIView, to: CGFloat) {
        let pointDestination = CGPoint(x: to, y: 18)
        UIView.animate(withDuration: 0.5, animations: {
            point.center = pointDestination
        }, completion: nil)
    }
    
    private func moveStartLine(to: CGFloat) {
        let a = (draggableZoneWidth * to / 100)
        let dest = a + (1 + 2*circleRadius + thumbSize - 10) + line!.bounds.size.width / 2
        let pointDestination = CGPoint(x: dest, y: 18)
        UIView.animate(withDuration: 0.2, animations: {
            self.line!.center = pointDestination
        }, completion: nil)
    }
    
    private func moveLineToCenter(animated: Bool) {
        let center = (firstValue + secondValue)/2
        let XPosition = (draggableZoneWidth * center / 100) + thumbSize/2
        
        
        if animated {
            UIView.animate(withDuration: 0.5, animations: {
                self.line?.center = CGPoint(x: XPosition, y: 18)
            }, completion: nil)
        } else {
            line?.center = CGPoint(x: XPosition, y: 18)
        }
    }
    
    private func changeLineSize(animated: Bool) {
        let center = (secondValue - firstValue)
        let width = ( center * draggableZoneWidth / 100)
        if animated {
            UIView.animate(withDuration: 0.5, animations: {
                self.line!.bounds.size.width = width
            }, completion: nil)
        } else {
            line!.bounds.size.width = width
        }
    }
    
    private func calculateLineSize() -> CGFloat {
        let center = (secondValue - firstValue)
        return( center * draggableZoneWidth / 100)
    }
    
    private func drag(circle: UIView, to: CGFloat, value: String){
        if (value == "firstValue") {
            firstValue += to * 100 / draggableZoneWidth
            circle.center = CGPoint(x:circle.center.x + to, y:18)
        }
        
        if (value == "secondValue") {
            secondValue += to * 100 / draggableZoneWidth
            circle.center = CGPoint(x:circle.center.x + to, y:18)
        }
    }
}







