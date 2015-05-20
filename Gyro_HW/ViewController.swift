//
//  ViewController.swift
//  Gyro_HW
//
//  Created by Bingqing Xia on 5/18/15.
//  Copyright (c) 2015 TYX. All rights reserved.
//

import UIKit
import CoreMotion
import QuartzCore

class ViewController: UIViewController {
    
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeight = UIScreen.mainScreen().bounds.height
    var photo: UIImageView!
    var isZoomed: Bool!
    var isZooming: Bool!
    lazy var motionManager = CMMotionManager()
    var previousX: CGFloat!
    var currentX: CGFloat!
    
    var lineLayer: CAShapeLayer!
    var link: CADisplayLink!
    var bezierPath: UIBezierPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //start gyro
        self.motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue.currentQueue(), withHandler: {motion, error in self.calculateRotationBasedOnGyro(motion)})

        
        self.view.backgroundColor = UIColor.blackColor()
        
        self.photo = UIImageView(frame: CGRectMake(0.0, self.screenHeight / 2 - self.screenWidth / 3, self.screenWidth, self.screenWidth / 3 * 2))
       
        self.isZoomed = false
        self.isZooming = false
    
        //set double tap gesture on photo
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: "updateDoubleTap:")
        doubleTapGesture.numberOfTapsRequired = 2
        
        self.photo.image = UIImage(named: "Image1")
        self.view.addSubview(self.photo)
        self.photo.addGestureRecognizer(doubleTapGesture)
        self.photo.userInteractionEnabled = true
        
        self.lineLayer = CAShapeLayer()
        //initialize the bezier path
        self.bezierPath = self.drawLineFromPoint(CGPoint(x: 3.0, y: self.screenHeight - 2.0), toPoint: CGPoint(x: self.screenWidth - 3.0, y: self.screenHeight - 2.0))
        
        self.lineLayer.path = self.bezierPath.CGPath
        self.lineLayer.lineCap = kCALineCapRound
        self.lineLayer.strokeColor = UIColor.grayColor().CGColor
        self.lineLayer.lineWidth = 4.0
        self.view.layer.addSublayer(self.lineLayer)
    }
    
    func drawLineFromPoint(start: CGPoint, toPoint end: CGPoint) -> UIBezierPath {
        var path = UIBezierPath()
        path.moveToPoint(start)
        path.addLineToPoint(end)
        path.stroke()
        
        return path
        
    }
    
    
    func updateDoubleTap(recogizer: UITapGestureRecognizer){
        self.motionManager.stopDeviceMotionUpdates()
        if self.isZoomed == true {
            UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {self.photo.frame = CGRectMake(0.0, self.screenHeight / 2 - self.screenWidth / 3, self.screenWidth, self.screenWidth / 3 * 2)}, completion: {finished in self.isZoomed = false
                self.isZooming = false

            })
            self.bezierPath = self.drawLineFromPoint(CGPoint(x: 3.0, y: self.screenHeight - 2.0), toPoint: CGPoint(x: self.screenWidth - 3.0, y: self.screenHeight - 2.0))
            self.lineLayer.path = self.bezierPath.CGPath
        } else {
            self.previousX =  -self.screenHeight / 2 * 3 / 2 + self.screenWidth / 2
            
            UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {self.photo.frame = CGRectMake(( -self.screenHeight / 2 * 3 / 2) + self.screenWidth / 2, 0.0, self.screenHeight / 2 * 3, self.screenHeight)}, completion: {finished in self.isZoomed = true
                self.isZooming = false
            self.motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue.currentQueue(), withHandler: {motion, error in self.calculateRotationBasedOnGyro(motion)})
            })
            self.screenWidth / (self.screenHeight / 2 * 3) * self.screenWidth
    
            self.bezierPath = self.drawLineFromPoint(CGPoint(x: self.screenWidth / 2 - self.screenWidth / (self.screenHeight / 2 * 3) * self.screenWidth / 2, y: self.screenHeight - 2.0), toPoint: CGPoint(x: self.screenWidth / 2 + self.screenWidth / (self.screenHeight / 2 * 3) * self.screenWidth / 2, y: self.screenHeight - 2.0))
            
            self.lineLayer.path = self.bezierPath.CGPath
        }

    }

    
    func calculateRotationBasedOnGyro(motion: CMDeviceMotion){
        if self.isZoomed == true && self.isZooming == false {
            let xRotationRate = motion.rotationRate.x
            let yRotationRate = -motion.rotationRate.y
            let zRotationRate = motion.rotationRate.z
            if fabs(yRotationRate) > (fabs(xRotationRate) + fabs(zRotationRate)) {
                UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {self.photo.frame = self.changeXCoordinate(CGFloat(yRotationRate))}, completion: nil)
              self.screenWidth / (self.screenHeight / 2 * 3) * self.screenWidth
               
                self.bezierPath = self.drawLineFromPoint(CGPoint(x: -self.currentX * self.screenWidth / (self.screenHeight / 2 * 3) , y: self.screenHeight - 2.0), toPoint: CGPoint(x: -self.currentX * self.screenWidth / (self.screenHeight / 2 * 3) + self.screenWidth / (self.screenHeight / 2 * 3) * self.screenWidth, y: self.screenHeight - 2.0))
                
                
                self.lineLayer.path = self.bezierPath.CGPath
                
            }
            
            
        }
    }
    
    func changeXCoordinate(yRotationRate: CGFloat) -> CGRect {
        
        self.currentX = self.previousX - yRotationRate / 100 * self.screenHeight / 2 * 3
        
        if self.currentX < 0 && self.currentX > -self.screenHeight / 2 * 3 + self.screenWidth {
            self.previousX = self.currentX
        return CGRect(x: self.currentX, y: 0.0, width: self.screenHeight / 2 * 3, height: self.screenHeight)
        } else if self.currentX >= 0 {
            self.previousX = 0.0
            return CGRect(x: 0.0, y: 0.0, width: self.screenHeight / 2 * 3, height: self.screenHeight)
        } else {
            self.previousX = -self.screenHeight / 2 * 3 + self.screenWidth
            return CGRect(x: -self.screenHeight / 2 * 3 + self.screenWidth, y: 0.0, width: self.screenHeight / 2 * 3, height: self.screenHeight)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

