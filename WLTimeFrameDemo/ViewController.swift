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
        frameView.themeColor = UIColor.gray/*设置主题背景颜色*/
        frameView.timeFrameColor = UIColor.orange/*设置时间片段颜色*/
        frameView.pointer?.pointerColor = UIColor.red/*设置指针颜色*/
        frameView.delegate = self
        self.view.addSubview(frameView)
    }

}

extension ViewController: WLTimeFrameViewDelegate {
    func endDragging(at time: Date) {
        print("end Dragging")
    }
    
    func beginScroll(at time: Date) {
        print("begin scroll")
    }
    
    func didScroll(at time: Date) {
        print("did scroll")
    }
    
    func endDecelerating(at time: Date) {
        print("end decelerating")
    }
}

