//
//  ViewController.swift
//  BYStateScrollView
//
//  Created by ysq on 15/6/2.
//  Copyright (c) 2015年 sgxiang. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,BYStateDataSource,BYStateDelegate {

    var row = 0
    var isError = false
    
    @IBOutlet var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = .None
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.byStateDataSource = self
        tableView.byStateDelegate = self
        
        let load = UIBarButtonItem(title: "刷新", style: .Plain, target: self, action: "testError")
        self.navigationItem.rightBarButtonItem = load
        
        let remove = UIBarButtonItem(title: "清除", style: .Plain, target: self, action: "testRemove")
        self.navigationItem.leftBarButtonItem = remove
        
        tableView.byState = .Loading
        self.tableView.reloadData()
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(3 * NSEC_PER_SEC)), dispatch_get_main_queue()) { () -> Void in
            self.row = 100
            self.tableView.reloadData()
        }
        
    }
    
    func testError(){
        
        row = 0
        
        tableView.byState = .Loading
        tableView.reloadData()
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(3 * NSEC_PER_SEC)), dispatch_get_main_queue()) { () -> Void in
            self.isError = true
            self.tableView.byState = .Custom
            self.tableView.reloadData()
        }
        
    }
    
    func testRemove(){
        row = 0
        isError = false
        tableView.byState = .Custom
        tableView.reloadData()
    }

    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return row
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell")!
        cell.textLabel?.text = "\(indexPath.row)"
        return cell
    }

    //MARK : - state data source
    
    func byStateButtonAttributedText(scrollView: UIScrollView, forState: UIControlState) -> NSAttributedString? {
        if isError{
            return NSAttributedString(string: " 重新加载 ", attributes: [NSFontAttributeName:UIFont.systemFontOfSize(14),NSForegroundColorAttributeName:UIColor.grayColor()])
        }
        return nil
    }
    
    func byStateDetailAttributedText(scrollView: UIScrollView) -> NSAttributedString? {
        if isError{
            return NSAttributedString(string: "请检查您的网络设置", attributes: [NSFontAttributeName:UIFont.systemFontOfSize(13),NSForegroundColorAttributeName:UIColor.lightGrayColor()])
        }
        return nil
    }
    
    func byStateImage(scrollView: UIScrollView) -> UIImage? {
        if isError{
            return UIImage(named: "noInterNet")
        }else{
            return UIImage(named: "dataEmpty")
        }
    }
    
    func byStateLoaddingColor(scrollView: UIScrollView) -> UIColor? {
        return UIColor.redColor()
    }
    
    func byStateTitleAttributedText(scrollView: UIScrollView) -> NSAttributedString? {
        if isError{
            return NSAttributedString(string: "您的网络好像有问题哦", attributes: [NSFontAttributeName:UIFont.systemFontOfSize(18),NSForegroundColorAttributeName:UIColor.blackColor()])
        }else{
            return NSAttributedString(string: "没有更多数据了", attributes: [NSFontAttributeName:UIFont.systemFontOfSize(18),NSForegroundColorAttributeName:UIColor.blackColor()])
        }
    }
    
    func byStateCustomButton(scrollView: UIScrollView, button: UIButton?) {
        button?.layer.borderColor = UIColor.grayColor().CGColor
        button?.layer.borderWidth = 1.0
        button?.layer.cornerRadius = 4
    }
    
    //MARK: - state delegate
    
    func byStateTapAction(scrollView: UIScrollView) {
        row = 100
        tableView.reloadData()
    }

}

