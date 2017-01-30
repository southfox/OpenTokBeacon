//
//  BeaconManager.swift
//  OpenTokBeacon
//
//  Created by javierfuchs on 1/27/17.
//  Copyright © 2017 OpenTok. All rights reserved.
//

import Foundation
import Eddystone


/// Notification for when BeaconManager has completely restored its state.
let BeaconManagerDidRestoreStateNotification: NSNotification.Name = NSNotification.Name(rawValue: "BeaconManagerDidRestoreStateNotification")

let BeaconManagerBeaconDetectedSTARTNotification: NSNotification.Name = NSNotification.Name(rawValue: "BeaconManagerBeaconDetectedSTARTNotification")
let BeaconManagerBeaconDetectedACKNotification: NSNotification.Name = NSNotification.Name(rawValue: "BeaconManagerBeaconDetectedACKNotification")
let BeaconManagerBeaconDetectedNACKNotification: NSNotification.Name = NSNotification.Name(rawValue: "BeaconManagerBeaconDetectedNACKNotification")

public class BeaconManager: Eddystone.ScannerDelegate {
    var uids = Eddystone.Scanner.nearbyUids
    var previousUids: [Eddystone.Uid] = []
    var isStarted: Bool
    
    public static let instance = BeaconManager()
    
    required public init() {
        isStarted = false
    }
    
    func start() {
        if (isStarted) {
            return;
        }
        isStarted = true
        Eddystone.Scanner.start(self)
        NotificationCenter.default.post(name: BeaconManagerBeaconDetectedSTARTNotification, object: nil)
    }
    func stop() {
        isStarted = false
    }
    
   
    public func eddystoneNearbyDidChange() {
        self.previousUids = self.uids
        self.uids = Eddystone.Scanner.nearbyUids
        for uid in self.previousUids {
            if !self.uids.contains(uid) {
                NotificationCenter.default.post(name:BeaconManagerBeaconDetectedNACKNotification, object: uid)
                break
            }
        }
        for uid in self.uids {
            if !self.previousUids.contains(uid) {
                NotificationCenter.default.post(name: BeaconManagerBeaconDetectedACKNotification, object: uid)
                break
            }
        }
    }
    
}
