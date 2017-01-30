//
//  StreamListManager.swift
//  OpenTokBeacon
//
//  Created by javierfuchs on 1/30/17.
//  Copyright © 2017 OpenTok. All rights reserved.
//

import Foundation
import AVFoundation
import ObjectMapper
import Alamofire
import AlamofireObjectMapper

/// Notification for when SessionListManager has completely restored its state.
let SessionListManagerDidRestoreStateNotification: NSNotification.Name = NSNotification.Name(rawValue: "SessionListManagerDidRestoreStateNotification")


class SessionListManager: NSObject {
    // MARK: Properties
    
    var isStarted: Bool

    /// A singleton instance of SessionListManager.
    static let instance = SessionListManager()
    
    /// Notification for when download progress has changed.
    static let didLoadNotification = NSNotification.Name(rawValue: "SessionListManagerDidLoadNotification")
    
    static let errorNotification = NSNotification.Name(rawValue: "SessionListManagerErrorNotification")
    
    /// The internal array of Session structs.
    private var sessions = [Session]()
    
    // MARK: Initialization
    
    override private init() {
        isStarted = false
        super.init()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(handleSessionPersistenceManagerDidRestoreStateNotification(_:)), name: SessionListManagerDidRestoreStateNotification, object: nil)
    }
    
    deinit {
        stop()
        NotificationCenter.default.removeObserver(self, name: SessionListManagerDidRestoreStateNotification, object: nil)
    }
    
    // MARK: Session access
    func start() {
        if (isStarted) {
            return;
        }
        isStarted = true
        NotificationCenter.default.post(name: SessionListManagerDidRestoreStateNotification, object: nil)
    }
    
    func stop() {
        isStarted = false
        sessions.removeAll()
    }

    /// Returns an Session for a given beacon id.
    func session(by id: String?) -> Session? {
        for session in sessions {
            if session.beacon_id == id {
                return session
            }
        }
        return nil
    }
    
    func handleSessionPersistenceManagerDidRestoreStateNotification(_ notification: Notification) {
        DispatchQueue.main.async {

            let sessionsJsonUrl = "http://192.168.250.185:3000" + "/sessions.json"
            
            Alamofire.request(sessionsJsonUrl, method:.get).validate().responseArray { (response: DataResponse<[Session]>) in
                if let result = response.result.value {
                    for entry in result {
                        // Get the Session name from the dictionary
                        self.sessions.append(entry)
                    }
                    NotificationCenter.default.post(name: SessionListManager.didLoadNotification, object: self)
                }
                else if let error = response.result.error {
                    NotificationCenter.default.post(name: SessionListManager.errorNotification, object: error)
                }
            }
        }
    }
}
