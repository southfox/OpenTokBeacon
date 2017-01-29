//
//  OpenTokManager.swift
//  OpenTokBeacon
//
//  Created by javierfuchs on 1/29/17.
//  Copyright © 2017 OpenTok. All rights reserved.
//

import Foundation
import OpenTok

class OpenTokManager: NSObject {

    public static let instance = OpenTokManager()
    var session : OTAcceleratorSession?
    
    override init() {
        super.init()
        session = OTAcceleratorSession.init(openTokApiKey: "", sessionId: "", token: "")
    }

}
