//
//  ConnectionManager.swift
//  TeleRobApp
//
//  Created by Antonio  Hernandez  on 9/6/16.
//  Copyright © 2016 Antonio  Hernandez . All rights reserved.
//

import Foundation
import Starscream

class ConnectionManager{
    var socket: WebSocket!
    init (ip: String, port:String)
        
    {
        print("ws://\(ip):\(port)/websocket")
        socket = WebSocket(url: NSURL(string: "ws://\(ip):\(port)/websocket")!)
        socket.delegate = self
        socket.connect()
    }

 
}
// MARK: Websocket Delegate Methods.
extension ConnectionManager: WebSocketDelegate  {
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
        print("Received text: \(text)")
    }
    
    func websocketDidReceiveData(ws: WebSocket, data: NSData) {
        print("Received data: \(data.length)")
    }
    
}
