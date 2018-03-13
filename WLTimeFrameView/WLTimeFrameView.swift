//
//  WLTimeView.swift
//  WLTimeFrame
//
//  Created by luowanglin on 2018/3/12.
//  Copyright © 2018年 luowanglin. All rights reserved.
//

import UIKit

/**
 *游标类
 */
class WLTimePointer: UIView {
    
    let lineWidth:CGFloat = 2.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let context: CGContext = UIGraphicsGetCurrentContext()!
        //直线
        context.setLineCap(CGLineCap.square)
        context.setLineWidth(lineWidth)
        context.beginPath()
        context.move(to: CGPoint.init(x: self.frame.width / 2, y: self.frame.height))
        context.addLine(to: CGPoint.init(x: self.frame.width / 2, y: 5.0))
        //三角形
        context.addLine(to: CGPoint.init(x: self.frame.width / 2 - 5.0, y: 0.0))
        context.addLine(to: CGPoint.init(x: self.frame.width / 2 + 5.0, y: 0.0))
        context.addLine(to: CGPoint.init(x: self.frame.width / 2, y: 5.0))
        UIColor.init(red: 0.82, green: 0.01, blue: 0.11, alpha: 1.0).setFill()
        UIColor.init(red: 0.82, green: 0.01, blue: 0.11, alpha: 1.0).setStroke()
        context.closePath()
        context.drawPath(using: CGPathDrawingMode.fillStroke)
    }
    
}

/**
 *协议
 */
protocol WLTimeFrameDelegate {
    func moveChange(time:String)
}

/**
 *主类
 */
class WLTimeFrameView: UIView {

    var timeScrollView: UICollectionView?
    var titleView: UILabel?
    let timeFrameCount = 1440//总的时间秒数
    var second: Int = 0
    var flagNum: CGFloat = 0.0
    var delegate: WLTimeFrameDelegate?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //滑动框
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout.init()
        layout.minimumLineSpacing = 0.0
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets.init(top: 0.0, left: frame.width / 2, bottom: 0.0, right: frame.width / 2)
        self.timeScrollView = UICollectionView.init(frame: CGRect.init(x: 0.0, y: 0.0, width: frame.width, height: frame.height), collectionViewLayout: layout)
        self.timeScrollView?.showsHorizontalScrollIndicator = false
        self.timeScrollView?.backgroundColor = UIColor.gray
        self.timeScrollView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        self.timeScrollView?.delegate = self
        self.timeScrollView?.dataSource = self
        self.addSubview(timeScrollView!)
        //初始化游标
        let pointer: WLTimePointer = WLTimePointer.init(frame: CGRect.init(x: 0.0, y: 0.0, width: 10, height: frame.height))
        pointer.center = CGPoint.init(x: frame.width / 2, y: frame.height / 2)
        pointer.setNeedsDisplay()
        self.addSubview(pointer)
        //提示标签
        self.titleView = UILabel.init(frame: CGRect.init(x: (UIScreen.main.bounds.width - 140.0) / 2, y: (timeScrollView?.frame.minY)! - 30.0, width: 140.0, height: 20.0))
        self.titleView?.backgroundColor = UIColor.gray
        self.titleView?.layer.cornerRadius = 10.0
        self.titleView?.layer.masksToBounds = true
        self.titleView?.textColor = UIColor.white
        self.titleView?.font = UIFont.systemFont(ofSize: 14.0)
        self.titleView?.textAlignment = .center
        self.titleView?.text = "03月12日 00:00:00"
        self.addSubview(self.titleView!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension WLTimeFrameView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return timeFrameCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        while (cell.contentView.subviews.last != nil) {
            cell.contentView.subviews.last?.removeFromSuperview()
        }
        cell.contentView.clipsToBounds = false
        cell.clipsToBounds = false
        //格式化title格式
        let textV: UILabel = UILabel.init(frame: CGRect.init(x: 0.0, y: 0.0, width: 30.0, height: 20.0))
        textV.textAlignment = .center
        let minuteStr:String = String(format:"%.2d",indexPath.item % 60)
        let hoursStr:String = String(format:"%.2d",indexPath.item / 60 )
        textV.text = "\(hoursStr):\(minuteStr)"
        textV.clipsToBounds = false
        textV.font = UIFont.systemFont(ofSize: 10.0)
        textV.textColor = UIColor.white
        //特殊化标尺高度
        var lineH = 10.0
        cell.backgroundColor = UIColor.clear
        if indexPath.item % 60 == 0 {
            lineH = 20.0
            textV.center = CGPoint.init(x: 0.0, y: 30.0)
            cell.contentView.addSubview(textV)
        }else if indexPath.item % 10 == 0{
            lineH = 15.0
            cell.backgroundColor = UIColor.orange
            textV.center = CGPoint.init(x: 0.0, y: 30.0)
            cell.contentView.addSubview(textV)
        }
        let line: UIView = UIView.init(frame: CGRect.init(x: 0.0, y: 0.0, width: 1.0, height: lineH))
        line.backgroundColor = UIColor.white
        cell.contentView.addSubview(line)
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("...\(scrollView.contentOffset.x)")
        let fieldNum:Int = Int(scrollView.contentOffset.x) / 15
        if flagNum < scrollView.contentOffset.x {
            //right
            second += 2
            if (second == 60) || (fieldNum % 60 == 0) {
                second = 0
            }
        }else{
            //left
            if second == 0 {
                second = 58
            }else{
                second -= 2
            }
        }
        flagNum = scrollView.contentOffset.x
        let secondStr:String = String(format:"%.2d",second)
        let minuteStr:String = String(format:"%.2d",fieldNum % 60)
        let hoursStr:String = String(format:"%.2d",fieldNum / 60 )
        self.titleView?.text = "03月12日 \(hoursStr):\(minuteStr):\(secondStr)"
        self.delegate?.moveChange(time: "\(hoursStr):\(minuteStr):\(secondStr)")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: 15.0, height: collectionView.frame.height)
    }
    
}

