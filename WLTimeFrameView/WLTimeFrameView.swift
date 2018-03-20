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
public class WLTimePointer: UIView {
    
    let lineWidth:CGFloat = 2.0
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func draw(_ rect: CGRect) {
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
public protocol WLTimeFrameViewDelegate {
    func moveChange(time:Date)
    func moveBegin(time:Date)
}

/**
 *Time区间模型
 */
public struct WLTimeSpaceModel{
    var startTime:CGFloat
    var endTime:CGFloat
}

/**
 *主类
 */
public class WLTimeFrameView: UIView {
    
    public var dateStr:String? {
        didSet{
            self.titleView?.text = "\(dateStr!) \(hoursStr):\(minuteStr):\(secondStr)"
        }
    }
    public var secondStr: String = "00"
    public var minuteStr: String = "00"
    public var hoursStr: String = "00"
    public var timeScrollView: UICollectionView?
    public var titleView: UILabel?
    private var timer: Timer?
    var isTouchBegin: Bool = false
    public let timeFrameCount = 1440//总的时间秒数
    var width_screen: CGFloat = UIScreen.main.bounds.width
    var second: Int = 0
    var flagNum: CGFloat = 0.0
    var margin_top: CGFloat = 40.0
    public var delegate: WLTimeFrameViewDelegate?
    var source: [WLTimeSpaceModel] = [WLTimeSpaceModel]() {
        didSet{
            for obj in (timeScrollView?.subviews)! {
                if obj.tag == 110 {
                    obj.removeFromSuperview()
                }
            }
            //偏移到播放位置
            timeScrollView?.contentOffset = CGPoint.init(x: CGFloat((source.first?.startTime)! / 4), y: 0.0)
            for (index,item) in source.enumerated() {
                let frameLineView:UIView = UIView.init(frame: CGRect.init(x: CGFloat(item.startTime / 4 + self.frame.width / 2), y: 0.0, width: (item.endTime / 4 - item.startTime / 4), height: self.frame.height))
                frameLineView.backgroundColor = UIColor.orange
                frameLineView.layer.zPosition = -1
                frameLineView.tag = index+1
                timeScrollView?.addSubview(frameLineView)
            }
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        //滑动框
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout.init()
        layout.minimumLineSpacing = 0.0
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets.init(top: 0.0, left: frame.width / 2, bottom: 0.0, right: frame.width / 2)
        self.timeScrollView = UICollectionView.init(frame: CGRect.init(x: 0.0, y: 0.0, width: self.frame.width, height: self.frame.height), collectionViewLayout: layout)
        self.timeScrollView?.showsHorizontalScrollIndicator = false
        self.timeScrollView?.backgroundColor = UIColor.gray
        self.timeScrollView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        self.timeScrollView?.delegate = self
        self.timeScrollView?.dataSource = self
        self.addSubview(timeScrollView!)
        //初始化游标
        let pointer: WLTimePointer = WLTimePointer.init(frame: CGRect.init(x: 0.0, y: 0.0, width: 10, height: self.frame.height))
        pointer.center = CGPoint.init(x: frame.width / 2, y: self.frame.height / 2)
        pointer.setNeedsDisplay()
        self.addSubview(pointer)
        //提示标签
        self.titleView = UILabel.init(frame: CGRect.init(x: (width_screen - 140.0) / 2, y: -30.0, width: 140.0, height: 20.0))
        self.titleView?.backgroundColor = UIColor.gray
        self.titleView?.layer.cornerRadius = 10.0
        self.titleView?.layer.masksToBounds = true
        self.titleView?.textColor = UIColor.white
        self.titleView?.font = UIFont.systemFont(ofSize: 14.0)
        self.titleView?.textAlignment = .center
        let dateFormat:DateFormatter = DateFormatter.init()
        dateFormat.dateFormat = "yyyy-MM-dd"
        dateStr = dateFormat.string(from: Date())
        hoursStr = "00"
        minuteStr = "00"
        secondStr = "00"
        self.titleView?.text = "\(dateStr!) \(hoursStr):\(minuteStr):\(secondStr)"
        self.addSubview(self.titleView!)
       
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension WLTimeFrameView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return timeFrameCount
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
        if indexPath.item % 60 == 0 {
            lineH = 20.0
            textV.center = CGPoint.init(x: 0.0, y: 30.0)
            cell.contentView.addSubview(textV)
        }else if indexPath.item % 10 == 0{
            lineH = 15.0
            textV.center = CGPoint.init(x: 0.0, y: 30.0)
            cell.contentView.addSubview(textV)
        }
        let line: UIView = UIView.init(frame: CGRect.init(x: 0.0, y: 0.0, width: 1.0, height: lineH))
        line.backgroundColor = UIColor.white
        cell.contentView.addSubview(line)
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let fieldNum:Int = Int(scrollView.contentOffset.x) / 15
        if flagNum < scrollView.contentOffset.x {
            //right
            second += 1
            if (second == 60) || (fieldNum % 60 == 0) {
                second = 0
            }
        }else{
            //left
            if second == 0 {
                second = 59
            }else{
                second -= 1
            }
        }
        flagNum = scrollView.contentOffset.x
        secondStr = String(format:"%.2d",Int(scrollView.contentOffset.x * 4) % 60)
        minuteStr = String(format:"%.2d",fieldNum % 60)
        hoursStr = String(format:"%.2d",fieldNum / 60 )
        self.titleView?.text = "\(hoursStr):\(minuteStr):\(secondStr)"
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let dateFormat: DateFormatter = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd hh:mm:ss"
        let date:Date? = dateFormat.date(from: "2018-03-20 \(hoursStr):\(minuteStr):\(secondStr)")
        self.delegate?.moveBegin(time: date!)
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let dateFormat: DateFormatter = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd hh:mm:ss"
        let date:Date? = dateFormat.date(from: "2018-03-20 \(hoursStr):\(minuteStr):\(secondStr)")
        self.delegate?.moveChange(time: date!)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: 15.0, height: collectionView.frame.height)
    }
    
}

