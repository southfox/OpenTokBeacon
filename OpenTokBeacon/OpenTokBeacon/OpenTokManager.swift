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

class OpenTokManager: NSObject, OTOneToOneCommunicatorDataSource {

    static let instance = OpenTokManager()
    var acceleratorSession: OTAcceleratorSession?
    var communicator : OTOneToOneCommunicator?
    var mainView: MainView?

    var apiKey: String?
    var sessionId: String?
    var tokenId: String?
    var isStarted: Bool
    
    override init() {
        isStarted = false
        
        super.init()
        
        observeNotifications()
    }
    
    func start() {
        if (isStarted) {
            return;
        }
        isStarted = true
    }
    func stop() {
        isStarted = false
    }

    private func observeNotifications()
    {
        unobserveNotifications()
        
        NotificationCenter.default.addObserver(forName: BeaconManagerBeaconDetectedSTARTNotification, object: nil, queue: OperationQueue.main) { (NSNotification) in
            // _ = showBeaconStarted
        }
        
        NotificationCenter.default
            .addObserver(forName: BeaconManagerBeaconDetectedACKNotification, object: nil,
                         queue: OperationQueue.main)  { [weak self]
                            note in
                            guard let beacon: Eddystone.Uid = note.object as? Eddystone.Uid
                                else { return }
                            
                            self?.showAlertBeacon(beacon: beacon, title: "Beacon detected")

                            // TODO: here connect from stream
                            self?.startCommunicationUsingBeacon(beacon: beacon)

        }
        
        NotificationCenter.default.addObserver(forName: BeaconManagerBeaconDetectedNACKNotification, object: nil,
                                               queue: OperationQueue.main) { [weak self]
                                                note in
                                                guard let beacon: Eddystone.Uid = note.object as? Eddystone.Uid
                                                    else
                                                {
                                                    return
                                                }
                                                self?.showAlertBeacon(beacon: beacon, title: "Beacon NOT detected")

                                                // TODO: here disconnect from stream
        }
    }
    
    
    private func showAlertBeacon(beacon: Eddystone.Uid, title: String) {
        var str = "Instance: \(beacon.instance)\n"
        str = str + "uid: \(beacon.uid)\n"
        let alert = SCLAlertView()
        alert.showSuccess(title, subTitle: str)
   }
    
    private func showError(error : Error?) {
        let alert = SCLAlertView()
        alert.addButton("Cancel") {}
        if let e = error {
            alert.showError("Error", subTitle: e.localizedDescription)
        }
    }
    
    public func useView(view:MainView) {
        mainView = view
    }
    
    private func unobserveNotifications()
    {
        for notification in [BeaconManagerBeaconDetectedSTARTNotification,
                             BeaconManagerBeaconDetectedACKNotification,
                             BeaconManagerBeaconDetectedNACKNotification]
        {
            NotificationCenter.default.removeObserver(self, name: notification, object: nil);
        }
    }
    
    private func stopCommunicationFromBeacon(beacon: Eddystone.Uid) {
        guard let view = mainView,
            let comm = communicator else {
                return
        }
        comm.disconnect()
        view.resetAllControl()
    }

    private func startCommunicationUsingBeacon(beacon: Eddystone.Uid) {
        guard let session = SessionListManager.instance.session(by: beacon.instance) else {
            return
        }
        acceleratorSession = OTAcceleratorSession.init(openTokApiKey: session.api_key,
                                                       sessionId: session.session_id,
                                                       token: session.token_id)

        let communicator = OTOneToOneCommunicator.init()
        communicator.dataSource = self
        
        communicator.connect { [weak self] (signal, error) in
            self?.communicator?.publisherView.showAudioVideoControl = false
            if let e = error {
                SCLAlertView.init().showError("Error", subTitle: e.localizedDescription)
            }
            else {
                self?.handleSignal(signal: signal)
                // TODO: handler of signal
            }
        }
    }
    
    func handleSignal(signal: OTCommunicationSignal) {
        guard let view = mainView,
              let comm = communicator else {
            return
        }
        switch signal {
        case .subscriberReady:
            // TODO: add a spinner
            view.connectCallHolder(comm.isCallEnabled)
            view.enableControlButtons(forCall: true)
            view.addPublisherView(comm.publisherView)
            if comm.isSubscribeToVideo {
                view.removeSubscriberView()
                view.addSubscribeView(comm.subscriberView)
            }
            break
        case .subscriberDestroyed:
            view.removeSubscriberView()
            break
        case .sessionDidBeginReconnecting:
            // spinner with reconnecting?
            break
        case .sessionDidReconnect:
            // spinner stop
            break
        case .publisherCreated:
            break
        case .publisherDestroyed:
            break
        case .subscriberCreated:
            if comm.isSubscribeToVideo {
                view.removeSubscriberView()
                view.addSubscribeView(comm.subscriberView)
            }
            break
        case .subscriberVideoDisabledByBadQuality: break
        case .subscriberVideoDisabledBySubscriber: break
        case .subscriberVideoEnabledByGoodQuality: break
        case .subscriberVideoEnabledBySubscriber: break
        case .subscriberVideoEnabledByPublisher:
            comm.isSubscribeToVideo = true
            break
        case .subscriberVideoDisableWarning:
            comm.isSubscribeToVideo = false
            break
        case .subscriberVideoDisableWarningLifted:
            comm.isSubscribeToVideo = true
            break
        default:
            break
        }
    }
 
    func sessionOfOTOne(_ oneToOneCommunicator: OTOneToOneCommunicator!) -> OTAcceleratorSession! {
        return acceleratorSession
    }
}
