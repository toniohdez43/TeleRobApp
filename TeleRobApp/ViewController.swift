//
//  ViewController.swift
//  TeleRobApp
//
//  Created by Antonio  Hernandez  on 9/6/16.
//  Copyright © 2016 Antonio  Hernandez . All rights reserved.
//

import UIKit
import Starscream

class ViewController: UIViewController{
    var connManager:ConnectionManager!
    var socket: WebSocket!
    override func viewDidLoad() {
        super.viewDidLoad()
        socket = WebSocket(url: NSURL(string: "ws://10.33.10.18:8000/websocket")!)
        socket.delegate = self
        socket.connect()
        //connManager = ConnectionManager(ip:"10.33.10.18",port: "8000")
        let image = UIImage(named: "ironman")
        videoStream.image = image
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
    }
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    
    @IBOutlet weak var videoStream: UIImageView!
    @IBAction func connect(sender: AnyObject) {
        
        socket = WebSocket(url: NSURL(string: "ws://10.33.10.18:8000/websocket")!)
        socket.delegate = self
        socket.connect()
    }
    
    // MARK: Write Text Action
    
    @IBAction func writeText(sender: UIButton) {
        socket.writeString("read_camera")
        print("preparing to send")
    }
    
    // MARK: Disconnect Action
    
    @IBAction func disconnect(sender: UIBarButtonItem) {
        if connManager.socket.isConnected {
            sender.title = "Connect"
            connManager.socket.disconnect()
        } else {
            sender.title = "Disconnect"
            connManager.socket.connect()
        }
    }
    
}
// MARK: Websocket Delegate Methods.
extension ViewController: WebSocketDelegate  {
    func websocketDidConnect(ws: WebSocket) {
        print("websocket is connected")
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
        print(ret)
        videoStream.image = ret
        
        //print("Received text: \(text)")
        
        
    }
    
    func websocketDidReceiveData(ws: WebSocket, data: NSData) {
        print("Received data: \(data.length) : \(data.description)")
    }

}