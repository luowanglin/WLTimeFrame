//
//  ViewController.swift
//  WLTimeFrame
//
//  Created by luowanglin on 2018/3/12.
//  Copyright © 2018年 luowanglin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let source:[WLTimeSpaceModel] = [WLTimeSpaceModel(startTime: 180.0, endTime: 220.0),WLTimeSpaceModel(startTime: 300.0, endTime: 400.0)]
        
        let frameView: WLTimeFrameView = WLTimeFrameView.init(frame: CGRect.init(x: 0.0, y: 100.0, width: UIScreen.main.bounds.width, height: 66.0))
        frameView.source = source
        self.view.addSubview(frameView)
    }

}

