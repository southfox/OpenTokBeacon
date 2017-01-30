//
//  MainViewController.swift
//  OpenTokBeacon
//
//  Created by javierfuchs on 1/27/17.
//  Copyright © 2017 OpenTok. All rights reserved.
//

import UIKit
import OpenTok
import SCLAlertView
import Eddystone
import NVActivityIndicatorView

@IBDesignable public class MainViewController: UIViewController,OTOneToOneCommunicatorDataSource {
    // @property (nonatomic) MainView *mainView;
    @IBOutlet var mainView: MainView!
//    var mainView: MainView!
    var acceleratorSession: OTAcceleratorSession?
    var communicator : OTOneToOneCommunicator?

    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        mainView = view as? MainView
        
        observeNotifications()
    }

    private func createCommunicator()
    {
        communicator = OTOneToOneCommunicator.init()
        guard let comm = communicator else {
            return
        }
        comm.dataSource = self
        
    }
    
    func call() {
        guard let comm = communicator,
            let view = mainView
            else {
                return
        }
        if comm.isCallEnabled == false {
            
            DispatchQueue.main.async { [unowned self] in
                
                comm.connect { [weak self] (signal, error) in
                    if let communicatorInside = self?.communicator,
                        let publisherView = communicatorInside.publisherView {
                        publisherView.showAudioVideoControl = false
                    }
                    if let e = error {
                        SCLAlertView.init().showError("Error", subTitle: e.localizedDescription)
                    }
                    else {
                        self?.handleSignal(signal: signal)
                    }
                }
            }
        }
        else {
            comm.disconnect()
            view.resetAllControl()
        }
        

    }

    @IBAction func callAction(_ sender: Any) {
        call()
    }

    private func startCommunicationUsingBeacon(beacon: Eddystone.Uid) {
        guard let session = SessionListManager.instance.session(by: beacon.instance)
            
            else {
                return
        }
        acceleratorSession = OTAcceleratorSession.init(openTokApiKey: session.api_key,
                                                       sessionId: session.session_id,
                                                       token: session.token_id)
        createCommunicator()
        
        call()
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
                            
//                            self?.showAlertBeacon(beacon: beacon, title: "Beacon detected")
                            
                            self?.startCommunicationUsingBeacon(beacon: beacon)
                            
        }
        
        NotificationCenter.default.addObserver(forName: BeaconManagerBeaconDetectedNACKNotification, object: nil,
                                               queue: OperationQueue.main) { [weak self]
                                                note in
                                                guard let comm = self?.communicator,
                                                    let view = self?.mainView
                                                    else {
                                                        return
                                                }
                                                comm.disconnect()
                                                view.resetAllControl()

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
    
    private func stopCommunicator() {
        guard let view = mainView,
            let comm = communicator else {
                return
        }
        comm.disconnect()
        view.resetAllControl()
    }
    
    
    
    public func sessionOfOTOne(_ oneToOneCommunicator: OTOneToOneCommunicator!) -> OTAcceleratorSession! {
        return acceleratorSession
    }

}

