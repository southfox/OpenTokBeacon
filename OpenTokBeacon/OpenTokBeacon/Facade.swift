//
//  Facade.swift
//  OpenTokBeacon
//
//  Created by javierfuchs on 1/30/17.
//  Copyright © 2017 OpenTok. All rights reserved.
//

import Foundation
open class Facade: NSObject {
    
    static func restart() {
        stop()
        start()
    }
    
    //
    // start service manager
    //
    static func start()
    {
        OpenTokManager.instance.start()
        SessionListManager.instance.start()
        BeaconManager.instance.start()
   }
    
    
    //
    // stop service manager
    //
    static func stop()
    {
        OpenTokManager.instance.stop()
        SessionListManager.instance.stop()
        BeaconManager.instance.stop()
    }

}
