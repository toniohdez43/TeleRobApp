//
//  UIMainController.swift
//  TeleRobApp
//
//  Created by Antonio  Hernandez  on 9/7/16.
//  Copyright © 2016 Antonio  Hernandez . All rights reserved.
//

import UIKit
import SwiftPi
import Starscream
import CoreMotion



class UIMainController: UIViewController {
    // Initial objects
    //let swiftPi = SwiftPi(username:"webiopi", password: "raspberry", ip:"10.33.10.18", port: "8000")
    var check = false
    var socket: WebSocket!
    var swiftPi : SwiftPi!
    var motionManager = CMMotionManager()
    var xIsValid = false
    var yIsValid = false
    //Camera
    
    // IBOutlets:
    
    @IBOutlet weak var imageVRview: GVRPanoramaView!
    @IBOutlet weak var cameraControl: UISegmentedControl!
    
    @IBOutlet weak var videoStream: UIImageView!
    
    @IBOutlet weak var ipField: UITextField!
    
    @IBOutlet weak var frontLightButton: UIButton!
    
    @IBOutlet weak var backLightButton: UIButton!
    
    @IBOutlet weak var rightLightButton: UIButton!
    
    @IBOutlet weak var leftLightButton: UIButton!
    
    @IBOutlet weak var reconnectButton: UIButton!
    
    
    //IBActions
    @IBAction func selectCamera(sender: AnyObject) {
        switch cameraControl.selectedSegmentIndex {
        case 0:
            print("CAMBIO")
            socket.disconnect()
            socket = WebSocket(url: NSURL(string: "ws://192.168.42.16:8000/websocket")!)
            socket.delegate = self
            socket.connect()
            
            break
        case 1:
            print("CAMBIO")
            socket.disconnect()
            socket = WebSocket(url: NSURL(string: "ws://10.33.8.140:8081/websocket")!)
            socket.delegate = self
            socket.connect()
            
            break
        default:
            break
        }
    }
    
    @IBAction func reconnect(sender: AnyObject) {
        socket.writeString("read_camera")
        print("preparing to send")
        
    }
    
    @IBAction func connect(sender: AnyObject) {
        if let ip = ipField.text{
            if ip==""{
               swiftPi = SwiftPi(username:"webiopi", password: "raspberry", ip:"10.33.10.18", port: "8000")
                

            
            }
            else{
               swiftPi = SwiftPi(username:"webiopi", password: "raspberry", ip:ip, port: "8000")
            }
           getLightStatus()
        }
    }
    
    @IBAction func toggleLight(sender: AnyObject) {
        
        switch sender as! NSObject {
        case frontLightButton:
            //.TWO
            checkAndToggle(frontLightButton, gpio: .TWO)
            break
        case backLightButton:
            checkAndToggle(backLightButton, gpio: .THREE)
            //.THREE
            break
        case rightLightButton:
            //.SEVENTEEN
            checkAndToggle(rightLightButton, gpio: .SEVENTEEN)
            break
        case leftLightButton:
            checkAndToggle(leftLightButton, gpio: .TWENTYSEVEN)
            //.TWENTYSEVEN
            break
        default:
            break
        }
        
    }
    //Request functions
    func httpRequest (valueX: String, valueY: String) -> NSURLRequest
    {
        
        
        let urlStr = "http://10.33.28.197:8888/cameraPos?X=\(valueX)&Y=\(valueY)"
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
    func getLightStatus(){
        //while(!check){
       swiftPi = SwiftPi(username:"webiopi", password: "raspberry", ip:"10.33.8.140", port: "8000")
            checkLight(frontLightButton, gpio: .TWO)
        
            checkLight(backLightButton, gpio: .THREE)
        
            checkLight(rightLightButton, gpio: .SEVENTEEN)
        
            checkLight(leftLightButton, gpio: .TWENTYSEVEN)
            //sleep(5)
       //}

    
        
    }
    func checkLight(button:UIButton, gpio: SwiftPi.GPIO){
        
        swiftPi.setModeInBackground(gpio, mode: .OUT) { (result)-> Void in
      
            self.swiftPi.getValueInBackground(gpio){ (result) -> Void in
                if let res = result {
                    //print(res)
                    //self.lblMode.text = res
                    switch res {
                        
                    case "1":
                        
                            button.backgroundColor = UIColor.greenColor()
                            button.alpha = 0.3
                            
                        
                        
                    case "0":
                        
                            button.backgroundColor = UIColor.grayColor()
                            button.alpha = 0.3
                            //
                            
                        
                        
                    default:
                        break
                    }
                    self.check = true
                    
                }
            }
        }
    }

    
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
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    func transformAngle(angle: Double)-> Double{
        return (abs(((angle + 40)%360) - 80) / 5) + 5;
        //return (Mathf.Abs(((grado + 40) % 360) - 80) / 5) + 5;
        
        
        
    }
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.gyroUpdateInterval = 0.1
        motionManager.startGyroUpdatesToQueue(NSOperationQueue.currentQueue()!, withHandler: {(accelerometerData: CMGyroData?, error: NSError?) -> Void in
            var x = 0.0
            var y = 0.0
            if (self.imageVRview.headRotation.pitch >= -90 && self.imageVRview.headRotation.pitch <= 90){
                x = self.transformAngle(Double(self.imageVRview.headRotation.pitch))
                y = self.transformAngle(Double(self.imageVRview.headRotation.yaw))
            }
            
            if (x<=21 && x>=5)
            {
                self.xIsValid =  true
                print("Around x: \(x)")
                
            }
            else{
                self.xIsValid = false
                
            }
            if (y<=21 && y>=5)
            {
                self.yIsValid =  true
                print("Around y: \(y)")
            }
            else{
                self.yIsValid = false
            }
            if (self.xIsValid && self.yIsValid){
                self.fireRequest(self.httpRequest("\(y)", valueY: "\(x)"))
            }
            
            if(error != nil){
                print("\(error)")
            }
            
            

            
        
        
        })
        let image = UIImage(named: "ironman")
        videoStream.image = image
        imageVRview.loadImage(image, ofType: .Mono)
        frontLightButton.layer.cornerRadius = 0.5 * frontLightButton.bounds.size.width
        backLightButton.layer.cornerRadius = 0.5 * frontLightButton.bounds.size.width
        rightLightButton.layer.cornerRadius = 0.5 * frontLightButton.bounds.size.width
        leftLightButton.layer.cornerRadius = 0.5 * frontLightButton.bounds.size.width
        reconnectButton.layer.cornerRadius = 0.7 * frontLightButton.bounds.size.width
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        socket = WebSocket(url: NSURL(string: "ws://192.168.42.16:8000/websocket")!)
        socket.delegate = self
        socket.connect()
        let timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: #selector(UIMainController.getLightStatus), userInfo: nil, repeats: true)
        imageVRview.enableCardboardButton = true
        imageVRview.enableFullscreenButton = true
    }

}
// MARK: Websocket Delegate Methods.
extension UIMainController:WebSocketDelegate  {
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
        
        
        videoStream.image = ret
        imageVRview.loadImage(ret, ofType: .Mono)
        //print("Received text: \(text)")
        
        
    }
    
    func websocketDidReceiveData(ws: WebSocket, data: NSData) {
        print("Received data: \(data.length) : \(data.description)")
    }
    
}
// MARK: Google Cardboard delegate Delegate Methods.
extension UIMainController:GVRCardboardViewDelegate{
    
    
    func cardboardView(cardboardView: GVRCardboardView!, didFireEvent event: GVRUserEvent) {
        //
    }
    func cardboardView(cardboardView: GVRCardboardView!, drawEye eye: GVREye, withHeadTransform headTransform: GVRHeadTransform!) {
        //
    }
    
    
    
    func cardboardView(cardboardView: GVRCardboardView!, shouldPauseDrawing pause: Bool) {
        //
    }

    func cardboardView(cardboardView: GVRCardboardView!, prepareDrawFrame headTransform: GVRHeadTransform!) {
        //
    }
    func cardboardView(cardboardView: GVRCardboardView!, willStartDrawing headTransform: GVRHeadTransform!) {
        //
    }
}

