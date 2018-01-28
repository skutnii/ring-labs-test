//
//  FullImageView.swift
//  RingLabsTest
//
//  Created by Serge Kutny on 1/28/18.
//  Copyright © 2018 skutnii. All rights reserved.
//

import UIKit

class FullImageView: UIView {

    lazy var imageView: UIImageView = {
        [unowned self] in
        let image: UIImageView =  self.makeSubview()
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    lazy var spinner: UIActivityIndicatorView = { [unowned self] in
        let spinner = UIActivityIndicatorView(activityIndicatorStyle:.gray)
        self.insertSubview(spinner, aboveSubview: self.imageView)
        spinner.hidesWhenStopped = true
        spinner.stopAnimating()
        return spinner
    }()
    
    override init(frame:CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
        
        let spinSize = spinner.frame.size
        var origin = bounds.origin
        origin.x += 0.5 * (bounds.size.width - spinSize.width)
        origin.y += 0.5 * (bounds.size.height - spinSize.height)
        spinner.frame = CGRect(origin: origin, size:spinSize)
    }
}
