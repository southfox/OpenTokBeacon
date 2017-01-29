//
//  BeaconManager.swift
//  OpenTokBeacon
//
//  Created by javierfuchs on 1/27/17.
//  Copyright © 2017 OpenTok. All rights reserved.
//

import Foundation
import Eddystone

public class BeaconManager: Eddystone.ScannerDelegate {
    struct notification {
        struct beacon {
            static let start : String = "notification.beacon.start"
            struct detected {
                static let ack : String = "notification.beacon.detected.ack"
                static let nack : String = "notification.beacon.detected.nack"
            }
        }
    }
    var uids = Eddystone.Scanner.nearbyUids
    var previousUids: [Eddystone.Uid] = []
    
    public static let instance = BeaconManager()
    
    func start() {
        Eddystone.Scanner.start(self)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: notification.beacon.start), object: nil)
    }
    
    public func eddystoneNearbyDidChange() {
        self.previousUids = self.uids
        self.uids = Eddystone.Scanner.nearbyUids
        for uid in self.previousUids {
            if !self.uids.contains(uid) {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: notification.beacon.detected.nack), object: uid)
                break
            }
        }
        for uid in self.uids {
            if !self.previousUids.contains(uid) {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: notification.beacon.detected.ack), object: uid)
                break
            }
        }
    }
    
}
