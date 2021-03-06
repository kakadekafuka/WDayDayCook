//
//  DetailHeaderView.swift
//  WDayDayCook
//
//  Created by wangju on 16/7/30.
//  Copyright © 2016年 wangju. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher

protocol DetailHeaderViewDelegate {
    func videoButtonClicked(_ detailsUrl:String?,id:Int?)
}

class DetailHeaderView: UIView {
    
    var imageUrl:String?{
        didSet{
            imageView.kf.setImage(with: URL(string: imageUrl!))
        }
    }
    
    
    var delegate : DetailHeaderViewDelegate?
    
    var detailsUrl:String?
    
    var id:Int?
    
    lazy var videoButton:UIButton = {
    
        let button = UIButton()
        button.setImage(UIImage(named: "食谱详情icon－Play~iphone"), for: UIControlState())
        button.sizeToFit()
        button.isHidden = true
        button.addTarget(self, action: #selector(videoButtonClicked), for: .touchUpInside)
        return button
    
    }()

    lazy var imageView: UIImageView = {
    
        let imageView = UIImageView()
        return imageView
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        makeUI()
    }
    
    func makeUI()
    {
        addSubview(imageView)
        addSubview(videoButton)
        imageView.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.trailing.equalTo(self)
            make.leading.equalTo(self)
            make.bottom.equalTo(self)
        }
        
        videoButton.snp.makeConstraints { (make) in
            make.center.equalTo(self)
        }   
    }
    
    @objc func videoButtonClicked()
    {
        if let delegate = delegate
        {
            delegate.videoButtonClicked(detailsUrl,id: self.id)
        }
    }



}
