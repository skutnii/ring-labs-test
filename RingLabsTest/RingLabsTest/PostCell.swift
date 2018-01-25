//
//  PostCell.swift
//  RingLabsTest
//
//  Created by Serge Kutny on 1/25/18.
//  Copyright © 2018 skutnii. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell {
    static let ID = "PostCell"
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init() {
        super.init(style: UITableViewCellStyle.default, reuseIdentifier:PostCell.ID)
    }
    
    var post : Post? {
        didSet {
            //Update UI
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
