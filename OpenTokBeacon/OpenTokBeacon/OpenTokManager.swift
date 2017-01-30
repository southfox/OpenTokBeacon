//
//  OpenTokManager.swift
//  OpenTokBeacon
//
//  Created by javierfuchs on 1/29/17.
//  Copyright © 2017 OpenTok. All rights reserved.
//

import Foundation
import OpenTok
import SCLAlertView
import Eddystone
import NVActivityIndicatorView

class OpenTokManager: NSObject {

    static let instance = OpenTokManager()

    var apiKey: String?
    var sessionId: String?
    var tokenId: String?
    var isStarted: Bool
    
    override init() {
        isStarted = false
        
        super.init()
    }
    
    func start() {
        if (isStarted) {
            return;
        }
        isStarted = true
    }
    func stop() {
        isStarted = false
//        stopCommunicator()
    }

}
