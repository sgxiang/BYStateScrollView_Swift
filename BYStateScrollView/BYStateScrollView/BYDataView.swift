//
//  BYDataView.swift
//  BYStateScrollView
//
//  Created by ysq on 15/9/15.
//  Copyright © 2015年 sgxiang. All rights reserved.
//

import UIKit

public class BYDataView : UIView{
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    @IBOutlet weak var imageViewAndTitleLabelPaddingLC: NSLayoutConstraint!
    @IBOutlet weak var titleLabelAndDetailLabelPaddingLC: NSLayoutConstraint!
    @IBOutlet weak var detailLabelAndButtonPaddingLC: NSLayoutConstraint!
    
    @IBOutlet weak var imageViewWidthLC: NSLayoutConstraint!
    @IBOutlet weak var imageViewHeightLC: NSLayoutConstraint!
    
    var useLoading = false
    
    var tapButtonAction : (()->())?
    
    init(){
        super.init(frame:CGRectZero)
    }
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    func setup(){
        if useLoading{
            contentView.hidden = true
            activityView.hidden = false
            activityView.startAnimating()
        }else{
            contentView.hidden = false
            activityView.hidden = true
            activityView.stopAnimating()
        }
        setupConstraints()
    }
    
    public override func didMoveToSuperview() {
        contentView.alpha = 0
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.contentView?.alpha = 1.0
        }, completion: nil)
    }
    
    private func canShowImage()->Bool{
        return imageView.image != nil
    }
    private func canShowTitle()->Bool{
        return titleLabel?.attributedText?.length > 0
    }
    private func canShowDetail()->Bool{
        return detailLabel?.attributedText?.length > 0
    }
    private func canShowButton()->Bool{
        return button?.attributedTitleForState(.Normal)?.length > 0
    }
    
    @IBAction func tapButton(sender: AnyObject) {
        tapButtonAction?()
    }
    
    private func setupConstraints() {
        
        let padding : CGFloat = 13
        
        if !useLoading{
            imageView.hidden = !canShowImage()
            titleLabel.hidden = !canShowTitle()
            imageViewAndTitleLabelPaddingLC.constant = canShowTitle() ? padding : 0
            detailLabel.hidden = !canShowDetail()
            titleLabelAndDetailLabelPaddingLC.constant = canShowDetail() ? padding : 0
            button.hidden = !canShowButton()
            detailLabelAndButtonPaddingLC.constant = canShowButton() ? padding : 0
            imageViewWidthLC.constant = imageView.image?.size.width ?? 0
            imageViewHeightLC.constant = imageView.image?.size.height ?? 0
        }
        
    }
}
