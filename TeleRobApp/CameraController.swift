//
//  CameraController.swift
//  TeleRobApp
//
//  Created by Antonio  Hernandez  on 10/17/16.
//  Copyright © 2016 Antonio  Hernandez . All rights reserved.
//

import UIKit
import SwiftPi
import Starscream
import CoreMotion

class CameraController: UIViewController {
    var socket: WebSocket!
    var swiftPi : SwiftPi!
    var motionManager = CMMotionManager()
    var xIsValid = false
    var yIsValid = false
    var selectedCamera = false
    var tracker : GVRPanoramaView!

    @IBOutlet weak var leftStream: UIImageView!
    
    @IBOutlet weak var headTracker: UIView!
    @IBOutlet weak var rightStream: UIImageView!
    //Request functions
    func httpRequest (valueX: String, valueY: String) -> NSURLRequest
    {
        
        
        let urlStr = "http://192.168.42.1:8888/cameraPos?X=\(valueX)&Y=\(valueY)"
        let url = NSURL(string: urlStr)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "GET"
        //request.setValue("Basic \(loginString(username, password: password))", forHTTPHeaderField: "Authorization")
        return request
        
        
    }
    
    func fireRequest(request:NSURLRequest) -> String {
        var responseString:NSString! = "Error"
        // fire off the request
        var response: NSURLResponse?
        do {
            let data = try NSURLConnection.sendSynchronousRequest(request, returningResponse: &response)
            responseString = NSString(data: data, encoding: NSUTF8StringEncoding)
            print("responseString = \(responseString!)")
            return responseString as String
        } catch (let e) {
            print(e)
            return responseString as String
        }
    }
    
    //Functions
    
    
    func checkAndToggle(button:UIButton, gpio: SwiftPi.GPIO){
        
        swiftPi.setModeInBackground(gpio, mode: .OUT) { (result)-> Void in
            
            self.swiftPi.getValueInBackground(gpio){ (result) -> Void in
                if let res = result {
                    //print(res)
                    //self.lblMode.text = res
                    switch res {
                        
                    case "1":
                        self.swiftPi.setValueInBackground(gpio, value: .OFF){ (result)-> Void in
                            button.backgroundColor = UIColor.grayColor()
                            button.alpha = 0.3
                            
                        }
                        
                    case "0":
                        self.swiftPi.setValueInBackground(gpio, value: .ON){ (result)-> Void in
                            button.backgroundColor = UIColor.greenColor()
                            button.alpha = 0.3
                            //
                            
                        }
                        
                    default:
                        break
                    }
                }
            }
        }
    }
    func recalibrate(){
        print("RECALIBRANDO.....")
        var tracker = GVRPanoramaView()
        tracker.loadImage(nil)
        tracker = headTracker as! GVRPanoramaView
        tracker.loadImage(UIImage(named: "ironman"))
        //headTracker.finalize()
        //headTracker.loadImage(nil)
        
        //viewDidLoad()
        
    }
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    func transformAngle(angle: Double)-> Double{
        return (abs(((angle + 40)%360) - 80) / 5) + 5;
        //return (Mathf.Abs(((grado + 40) % 360) - 80) / 5) + 5;
        
    
        
    }
    func transformMirrorAngle(angle: Double)->Double{
        return 21-(21%(angle+16))
    }
    func transformAngleServo(angle: Double)->Double{
        return ((14/5)*(angle+40)+638)/100
    }
    
    func toggleCamera(){
        selectedCamera = !selectedCamera
        switch selectedCamera {
        case false:
            print("CAMBIO")
            socket.disconnect()
            socket = WebSocket(url: NSURL(string: "ws://192.168.42.1:8000/websocket")!)
            socket.delegate = self
            socket.connect()
            
            break
        case true:
            print("CAMBIO")
            socket.disconnect()
            socket = WebSocket(url: NSURL(string: "ws://192.168.42.16:8000/websocket")!)
            socket.delegate = self
            socket.connect()
            
            break
        default:
            break
        }

    }
    
    func deltaAngle(actualValue: Double, previousValue: Double) -> Bool{
        if abs(previousValue-actualValue) >= 1
        {
            return true
        }
        
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tracker = headTracker as! GVRPanoramaView
        tracker.loadImage(UIImage(named: "ironman"))
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.gyroUpdateInterval = 0.1
        motionManager.startGyroUpdatesToQueue(NSOperationQueue.currentQueue()!, withHandler: {(accelerometerData: CMGyroData?, error: NSError?) -> Void in
            var prevX = 0.0
            var prevY = 0.0
            var x = 0.0
            var y = 0.0
            if (self.tracker.headRotation.pitch >= -40 && self.tracker.headRotation.pitch <= 40 && self.tracker.headRotation.yaw >= -40 && self.tracker.headRotation.yaw <= 40){
                //x = self.transformAngleServo(Double(self.headTracker.headRotation.pitch))
                //print(self.imageVRview.headRotation.pitch)
                //y = self.transformAngleServo(Double(self.headTracker.headRotation.yaw))
                
                x = Double(self.tracker.headRotation.pitch) + 90.0
                y = abs(Double(self.tracker.headRotation.yaw) - 90.0)
                if (self.deltaAngle(x, previousValue: prevX) || self.deltaAngle(y, previousValue: prevY)){
                    prevY = y
                    prevX = x
                    print("Around x: \(x)")
                    print("Around y: \(y)")
                    self.fireRequest(self.httpRequest("\(y)", valueY: "\(x)"))
                
                }
                //y = self.transformMirrorAngle(y)
                //print(self.imageVRview.headRotation.yaw)
                
            }
            
        })
        let image = UIImage(named: "ironman")
       
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CameraController.toggleCamera))
        let doubleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CameraController.recalibrate))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.cancelsTouchesInView = false
        tap.cancelsTouchesInView = false
        view.userInteractionEnabled = true
        view.addGestureRecognizer(doubleTap)
        view.addGestureRecognizer(tap)
        socket = WebSocket(url: NSURL(string: "ws://192.168.42.1:8000/websocket")!)
        socket.delegate = self
        socket.connect()
        //let timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: #selector(UIMainController.getLightStatus), userInfo: nil, repeats: true)
        
    }
    


    
    
    
}
// MARK: Websocket Delegate Methods.
extension CameraController:WebSocketDelegate  {
    func websocketDidConnect(ws: WebSocket) {
        print("websocket is connected")
        socket.writeString("read_camera")
        print("preparing to send")
    }
    
    func websocketDidDisconnect(ws: WebSocket, error: NSError?) {
        if let e = error {
            print("websocket is disconnected: \(e.localizedDescription)")
        } else {
            print("websocket disconnected")
        }
    }
    
    func websocketDidReceiveMessage(ws: WebSocket, text: String) {
        
        
        let header = "data:image/jpeg;base64,\(text)"
        
        let url = NSURL(string: header)
        let imageData = NSData(contentsOfURL: url!)
        let data  = NSData(base64EncodedString: header, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters  )
        //print(data!)
        let ret = UIImage(data: imageData!)
        
        
        leftStream.image = ret
        rightStream.image = ret
        //imageVRview.addSubview(videoStream)
        
        
        
    }
    
    func websocketDidReceiveData(ws: WebSocket, data: NSData) {
        print("Received data: \(data.length) : \(data.description)")
    }
    
}

