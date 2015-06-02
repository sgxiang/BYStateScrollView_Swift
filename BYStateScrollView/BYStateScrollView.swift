//
//  BYStateScrollView.swift
//  BYStateScrollView
//
//  Created by ysq on 15/6/2.
//  Copyright (c) 2015年 sgxiang. All rights reserved.
//

import UIKit

private var stateKey : UInt8 = 0
private var viewKey : UInt8 = 0
private var dataSourceKey : UInt8 = 0

public enum BYState : Int{
    case Default = 0
    case Loading = 1
    case Event = 2
}

@objc public protocol BYStateDataSource : NSObjectProtocol {
    
    @objc optional func byStateTitleAttributedText( scrollView : UIScrollView ) -> NSAttributedString?
    @objc optional func byStateDetailAttributedText( scrollView : UIScrollView ) -> NSAttributedString?
    @objc optional func byStateImage( scrollView : UIScrollView ) -> UIImage?
    @objc optional func byStateButtonAttributedText( scrollView : UIScrollView , forState : UIControlState) -> NSAttributedString?
    @objc optional func byStateLoaddingColor (scrollView : UIScrollView ) -> UIColor?
    @objc optional func byStateAction (scrollView : UIScrollView )
    
}


private class BYDataView : UIView{
    
    lazy var contentView : UIView? = {
        let cv = UIView()
        cv.setTranslatesAutoresizingMaskIntoConstraints(false)
        cv.backgroundColor = UIColor.clearColor()
        cv.userInteractionEnabled = true
        cv.alpha = 0
        return cv
    }()
    
    
    var titleLabel : UILabel?
    var detailLabel : UILabel?
    var imageView : UIImageView?
    var button : UIButton?
    var activityView : UIActivityIndicatorView?
    
    var useLoading = false
    
    var dataViewAction : (()->())?
    
    init(){
        super.init(frame:CGRectZero)
        self.addSubview(contentView!)
    }
    
    private func setupDetailView(){
        
        if useLoading{
            activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
            activityView?.startAnimating()
            contentView?.addSubview(activityView!)
        }else{
            
            if titleLabel == nil{
                titleLabel = UILabel()
                titleLabel?.setTranslatesAutoresizingMaskIntoConstraints(false)
                titleLabel?.backgroundColor = UIColor.clearColor()
                titleLabel?.font = UIFont.systemFontOfSize(27)
                titleLabel?.textColor = UIColor(white: 0.6, alpha: 1)
                titleLabel?.textAlignment = .Center
                titleLabel?.lineBreakMode = .ByWordWrapping
                titleLabel?.numberOfLines = 2
                titleLabel?.accessibilityLabel = "empty set title label"
                contentView?.addSubview(titleLabel!)
            }
            if detailLabel == nil{
                detailLabel = UILabel()
                detailLabel?.setTranslatesAutoresizingMaskIntoConstraints(false)
                detailLabel?.backgroundColor = UIColor.clearColor()
                detailLabel?.font = UIFont.systemFontOfSize(17)
                detailLabel?.textColor = UIColor(white: 0.6, alpha: 1)
                detailLabel?.textAlignment = .Center
                detailLabel?.lineBreakMode = .ByWordWrapping
                detailLabel?.numberOfLines = 0
                detailLabel?.accessibilityLabel = "empty set detail label"
                contentView?.addSubview(detailLabel!)
            }
            if imageView == nil{
                imageView = UIImageView()
                imageView?.setTranslatesAutoresizingMaskIntoConstraints(false)
                imageView?.backgroundColor = UIColor.clearColor()
                imageView?.contentMode = .ScaleAspectFit
                imageView?.userInteractionEnabled = false
                imageView?.accessibilityLabel = "empty set background image"
                contentView?.addSubview(imageView!)
            }
            if button == nil{
                button = UIButton.buttonWithType(.Custom) as? UIButton
                button?.setTranslatesAutoresizingMaskIntoConstraints(false)
                button?.backgroundColor = UIColor.clearColor()
                button?.contentHorizontalAlignment = .Center
                button?.contentVerticalAlignment = .Center
                button?.accessibilityLabel = "empty set button"
                button?.addTarget(self, action: "didTapButton:", forControlEvents: .TouchUpInside)
                contentView?.addSubview(button!)
            }
            
        }
        
    }


    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private override func didMoveToSuperview() {
        self.frame = self.superview?.bounds ?? CGRectZero
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.contentView?.alpha = 1.0
        }, completion: nil)
    }
    
    
    private func canShowImage()->Bool{
        return imageView?.image != nil && imageView?.superview != nil
    }
    private func canShowTitle()->Bool{
        return titleLabel?.attributedText?.length > 0 && titleLabel?.superview != nil
    }
    private func canShowDetail()->Bool{
        return detailLabel?.attributedText?.length > 0 && detailLabel?.superview != nil
    }
    private func canShowButton()->Bool{
        return button?.attributedTitleForState(.Normal)?.length > 0 && button?.superview != nil
    }
    
    @objc private func didTapButton(sender : UIButton){
        dataViewAction?()
    }
    
    func removeAllSubviews(){
        titleLabel?.removeFromSuperview()
        detailLabel?.removeFromSuperview()
        imageView?.removeFromSuperview()
        button?.removeFromSuperview()
        activityView?.removeFromSuperview()
        titleLabel = nil
        detailLabel = nil
        imageView = nil
        button = nil
        activityView = nil
    }
    
    func removeAllConstraints(){
        self.removeConstraints(self.constraints())
        contentView?.removeConstraints(contentView!.constraints())
    }
    
    private override func updateConstraintsIfNeeded() {
        super.updateConstraintsIfNeeded()
    }
    private override func updateConstraints() {
        
        removeAllConstraints()
        
        var views : Dictionary<String,AnyObject> = Dictionary()
        views["self"] = self
        views["contentView"] = self.contentView
        
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[self]-(<=0)-[contentView]", options: .AlignAllCenterY, metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[self]-(<=0)-[contentView]", options: .AlignAllCenterX, metrics: nil, views: views))
        
        
        if useLoading{
            views["activityView"] = activityView
            contentView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[activityView]|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
            contentView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[activityView]|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
            return super.updateConstraints()
        }
        
        let width = CGRectGetWidth(self.frame)
        let padding = 20
        let imgWidth = imageView?.image?.size.width ?? 0
        let imgHeight = imageView?.image?.size.height ?? 0
        let trailing = width - imgWidth / 2.0
        
        let metrics : Dictionary<String,AnyObject> = [
            "padding" : padding,
            "imgWidth" : imgWidth,
            "imgHeight" : imgHeight,
            "trailing" : trailing
        ]
        
        var verticalSubviews : NSMutableArray = NSMutableArray()
        
        if imageView?.superview != nil{
            views["imageView"] = imageView
            verticalSubviews.addObject("[imageView(imgHeight)]")
            contentView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-trailing-[imageView(imgWidth)]-trailing-|", options: NSLayoutFormatOptions(0) , metrics: metrics, views: views))
        }
        if self.canShowTitle(){
            views["titleLabel"] = titleLabel
            verticalSubviews.addObject("[titleLabel]")
            contentView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-padding-[titleLabel]-padding-|", options: NSLayoutFormatOptions(0), metrics: metrics, views: views))
        }else{
            titleLabel?.removeFromSuperview()
            titleLabel = nil
        }
        
        if self.canShowDetail(){
            views["detailLabel"] = detailLabel
            verticalSubviews.addObject("[detailLabel]")
            self.contentView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-padding-[detailLabel]-padding-|", options: NSLayoutFormatOptions(0), metrics: metrics, views: views))
        }else{
            detailLabel?.removeFromSuperview()
            detailLabel = nil
        }
        
        if self.canShowButton(){
            views["button"] = button
            verticalSubviews.addObject("[button]")
            self.contentView?.addConstraint(NSLayoutConstraint(item: button!, attribute: .CenterX, relatedBy: .Equal, toItem: contentView, attribute: .CenterX, multiplier: 1, constant: 0))
        }else{
            button?.removeFromSuperview()
            button = nil
        }
        
        let verticalFormat = verticalSubviews.componentsJoinedByString("-(11.0)-")
        
        if count(verticalFormat) > 0{
            contentView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|" + verticalFormat + "|", options: NSLayoutFormatOptions(0), metrics: metrics, views: views))
        }
        
        super.updateConstraints()
        
    }
}



private class BYClosureWrapper <T> : NSObject {
    
    let _callback : [T]
    
    init(_ callback : T ) {
        _callback = [callback]
    }
    
    var call : T {
        get{
            return _callback[0]
        }
    }
    
}


public extension UIScrollView{
    
    public var byStateDataSource : BYStateDataSource?{
        get{
            return objc_getAssociatedObject(self, &dataSourceKey) as? BYStateDataSource
        }
        set{
            objc_setAssociatedObject(self, &dataSourceKey, newValue, UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
        }
    }
    
    private var dataView : BYDataView?{
        get{
            var view = objc_getAssociatedObject(self, &viewKey) as? BYDataView
            if view == nil{
                view = BYDataView()
                view?.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
                view?.hidden = true
                self.dataView = view
            }
            return view
        }
        set{
            objc_setAssociatedObject(self, &viewKey, newValue, UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
        }
    }
    
    public var byState : BYState?{
        get{
            return BYState(rawValue: objc_getAssociatedObject(self, &stateKey) as! Int)
        }
        set{
            objc_setAssociatedObject(self, &stateKey, newValue!.rawValue, UInt(OBJC_ASSOCIATION_COPY))
            reloadBYStateView()
        }
    }
    
    public func reloadBYStateView(){
        
        (self as? UITableView)?.reloadData()
        (self as? UICollectionView)?.reloadData()
        
        if byState == .Default || itemCount() > 0{
            dataView?.removeAllSubviews()
            dataView?.removeFromSuperview()
        }else{
            
            let view = self.dataView
            if view?.superview == nil{
                if self.isKindOfClass(UITableView.self) || self.isKindOfClass(UICollectionView.self) && self.subviews.count > 1{
                    self.insertSubview(view!, atIndex: 1)
                }else{
                    self.addSubview(view!)
                }
            }
            view?.removeAllSubviews()
        
            view?.useLoading = byState == .Loading
            view?.setupDetailView()
            
            if byState == .Event && byStateDataSource != nil{
                
                view?.detailLabel?.attributedText = byStateDataSource?.byStateTitleAttributedText?(self)
                view?.titleLabel?.attributedText = byStateDataSource?.byStateDetailAttributedText?(self)
                view?.imageView?.image = byStateDataSource?.byStateImage?(self)
                
                
                if let str = byStateDataSource?.byStateButtonAttributedText?(self, forState: .Normal){
                    view?.button?.setAttributedTitle(str, forState: .Normal)
                }
                if let str = byStateDataSource?.byStateButtonAttributedText?(self, forState: .Highlighted){
                    view?.button?.setAttributedTitle(str, forState: .Highlighted)
                }
                
                view?.dataViewAction = {
                    byStateDataSource?.byStateAction?(self)
                }
        
            }
            
            view?.activityView?.color = byStateDataSource?.byStateLoaddingColor?(self)
            
            
            view?.hidden = false
            view?.layoutIfNeeded()
            view?.userInteractionEnabled = true
            
            view?.updateConstraints()
            
        }
    }
    
    private func itemCount()->NSInteger{
        var items = 0
        if let tableView = self as? UITableView{
            if let dataSource = tableView.dataSource where dataSource.respondsToSelector("numberOfSectionsInTableView:"){
                let section = dataSource.numberOfSectionsInTableView!(tableView)
                for var i = 0 ; i < section ; i++ {
                    items += dataSource.tableView(tableView, numberOfRowsInSection: i)
                }
            }
        }else if let collectionView = self as? UICollectionView{
            if let dataSource = collectionView.dataSource where dataSource.respondsToSelector("numberOfSectionsInCollectionView:"){
                let section = dataSource.numberOfSectionsInCollectionView!(collectionView)
                for var i = 0 ; i < section ; i++ {
                    items += dataSource.collectionView(collectionView, numberOfItemsInSection: i)
                }
            }
        }
        return items
    }
    
    
}