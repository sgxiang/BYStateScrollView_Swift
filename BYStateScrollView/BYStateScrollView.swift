//
//  BYStateScrollView.swift
//  BYStateScrollView
//
//  Created by ysq on 15/6/2.
//  Copyright (c) 2015年 sgxiang. All rights reserved.
//

import UIKit

//private var stateKey : UInt8 = 0
//private var viewKey : UInt8 = 0
//private var dataSourceKey : UInt8 = 0
//private var delegateKey : UInt8 = 0

public enum BYState : Int{
    case Loading = 0
    case Custom = 1
}

@objc public protocol BYStateDelegate {
    func byStateTapAction (scrollView : UIScrollView )
}

@objc public protocol BYStateDataSource : NSObjectProtocol {
    @objc optional func byStateTitleAttributedText( scrollView : UIScrollView ) -> NSAttributedString?
    @objc optional func byStateDetailAttributedText( scrollView : UIScrollView ) -> NSAttributedString?
    @objc optional func byStateImage( scrollView : UIScrollView ) -> UIImage?
    @objc optional func byStateButtonAttributedText( scrollView : UIScrollView , forState : UIControlState) -> NSAttributedString?
    @objc optional func byStateCustomButton( scrollView : UIScrollView , button : UIButton?)
}

public extension UIScrollView{
    
    private struct AssociatedKeys {
        static var StateKey = "StateKey"
        static var ViewKey = "ViewKey"
        static var DataSourceKey = "DataSourceKey"
        static var DelegateKey = "DelegateKey"
    }
    
    public var byStateDataSource : BYStateDataSource?{
        get{
            return objc_getAssociatedObject(self, &AssociatedKeys.DataSourceKey) as? BYStateDataSource
        }
        set{
            objc_setAssociatedObject(self, &AssociatedKeys.DataSourceKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var byStateDelegate : BYStateDelegate?{
        get{
            return objc_getAssociatedObject(self, &AssociatedKeys.DelegateKey) as? BYStateDelegate
        }
        set{
            objc_setAssociatedObject(self, &AssociatedKeys.DelegateKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var dataView : BYDataView?{
        get{
            var view = objc_getAssociatedObject(self, &AssociatedKeys.ViewKey) as? BYDataView
            if view == nil{
                view = NSBundle.mainBundle().loadNibNamed("BYDataView", owner: nil, options: nil)[0] as? BYDataView
                self.dataView = view
            }
            return view
        }
        set{
            objc_setAssociatedObject(self, &AssociatedKeys.ViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var byState : BYState?{
        get{
            return BYState(rawValue: objc_getAssociatedObject(self, &AssociatedKeys.StateKey) as! Int)
        }
        set{
            objc_setAssociatedObject(self, &AssociatedKeys.StateKey, newValue!.rawValue, .OBJC_ASSOCIATION_COPY)
        }
    }
    
    internal func reloadBYStateView(){
        
//        (self as? UITableView)?.reloadData()
//        (self as? UICollectionView)?.reloadData()
        
        if itemCount() > 0{
            dataView?.removeFromSuperview()
            dataView = nil
        }else{
            let view = self.dataView
            if view?.superview == nil{
                if self.isKindOfClass(UITableView.self) || self.isKindOfClass(UICollectionView.self) && self.subviews.count > 1{
                    self.insertSubview(view!, atIndex: 1)
                }else{
                    self.addSubview(view!)
                }
            }
            
            view?.frame = view?.superview?.frame ?? CGRectZero
            
            view?.useLoading = byState == .Loading
            
            if byState == .Custom && byStateDataSource != nil{
                view?.titleLabel?.attributedText = byStateDataSource?.byStateTitleAttributedText?(self)
                view?.detailLabel?.attributedText = byStateDataSource?.byStateDetailAttributedText?(self)
                view?.imageView?.image = byStateDataSource?.byStateImage?(self)
                
                let buttonNormalTitle = byStateDataSource?.byStateButtonAttributedText?(self, forState: .Normal) ?? NSAttributedString()
                view?.button?.setAttributedTitle(buttonNormalTitle, forState: .Normal)
                
                let buttonHighlightedTitle = byStateDataSource?.byStateButtonAttributedText?(self, forState: .Highlighted) ?? NSAttributedString()
                view?.button?.setAttributedTitle(buttonHighlightedTitle, forState: .Highlighted)
                
                view?.tapButtonAction = {
                    byStateDelegate?.byStateTapAction(self)
                }
                
                byStateDataSource?.byStateCustomButton?(self, button: view?.button)
            }
            
            view?.setup()
            
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


extension UITableView{
    
    public override class func initialize(){
        struct Static{
            static var token : dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) { () -> Void in
            let originalSelector = Selector("reloadData")
            let swizzledSelector = Selector("nsh_reloadData")
            
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
            
            let didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
            
            if didAddMethod{
                class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
            }else{
                method_exchangeImplementations(originalMethod, swizzledMethod)
            }
            
        }
    }
    
    func nsh_reloadData(){
        self.nsh_reloadData()
        self.reloadBYStateView()
    }
    
}


extension UICollectionView{
    
    public override class func initialize(){
        struct Static{
            static var token : dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) { () -> Void in
            let originalSelector = Selector("reloadData")
            let swizzledSelector = Selector("nsh_reloadData")
            
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
            
            let didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
            
            if didAddMethod{
                class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
            }else{
                method_exchangeImplementations(originalMethod, swizzledMethod)
            }
            
        }
    }
    
    func nsh_reloadData(){
        self.nsh_reloadData()
        self.reloadBYStateView()
    }
    
}
