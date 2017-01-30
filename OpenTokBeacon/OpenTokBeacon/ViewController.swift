//
//  ViewController.swift
//  OpenTokBeacon
//
//  Created by javierfuchs on 1/27/17.
//  Copyright © 2017 OpenTok. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    // @property (nonatomic) MainView *mainView;
    var mainView: MainView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        mainView = view as? MainView
        OpenTokManager.instance.useView(view: mainView!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

