//
//  PostCell.swift
//  RingLabsTest
//
//  Created by Serge Kutny on 1/25/18.
//  Copyright © 2018 skutnii. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell, Observer {
    
    class View : UIView {
        static let Height : CGFloat = 200.0
        static let Spacing : CGFloat = 8.0
        static let LineHeight: CGFloat = 20.0
        static let TitleHeight: CGFloat = 100.0
        
        lazy var thumbnail : UIButton = {
            [unowned self] in
            let button = UIButton(type:.custom)
            self.addSubview(button)
            button.addTarget(self, action: #selector(thumbClick(_:)), for: UIControlEvents.touchUpInside)
            return button
        } ()
        
        lazy var titleLabel : UILabel = { [unowned self] in
            let label : UILabel = self.makeSubview()
            label.font = UIFont.boldSystemFont(ofSize: 18.0)
            label.numberOfLines = 4
            label.lineBreakMode = .byWordWrapping
            return label
        } ()
        
        func makeInfo() -> UILabel {
            let label : UILabel = self.makeSubview()
            label.font = UIFont.systemFont(ofSize: 14.0)
            return label
        }
        
        var onThumbClick : (() -> ())?
        @objc func thumbClick(_ sender: AnyObject) {
            onThumbClick?()
        }
        
        lazy var authorLabel: UILabel = { [unowned self] in return self.makeInfo() } ()
        lazy var dateLabel: UILabel = { [unowned self] in return self.makeInfo() } ()
        lazy var commentsLabel: UILabel = { [unowned self] in return self.makeInfo() } ()
        
        override func layoutSubviews() {
            super.layoutSubviews()
            var x = bounds.origin.x + View.Spacing
            var y = bounds.origin.y + View.Spacing
            var labelWidth = bounds.size.width - 2 * View.Spacing
            
            titleLabel.frame = CGRect(origin: CGPoint(x:x, y:y),
                                      size:CGSize(width:labelWidth, height:View.TitleHeight))
            
            y += View.TitleHeight + View.Spacing
            
            if (nil == thumbnail.image(for: .normal)) {
                thumbnail.frame = CGRect.zero
            } else {
                let thumbSide = View.Height - View.TitleHeight - 3 * View.Spacing
                thumbnail.frame = CGRect(origin:CGPoint(x: x, y:y),
                                         size:CGSize(width: thumbSide, height: thumbSide))
                x += thumbSide + View.Spacing
                labelWidth -= thumbSide + View.Spacing
            }
            
            for label in [authorLabel, dateLabel, commentsLabel] {
                label.frame = CGRect(origin: CGPoint(x: x, y: y),
                                     size:CGSize(width: labelWidth, height: View.LineHeight))
                y += View.LineHeight + View.Spacing
            }
            
        }
    }
    
    static let ID = "PostCell"
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    var onPostThumbnailClick: ((Post?) -> ())?
    lazy var view: View = {
        [unowned self] in
        let view = View(frame: contentView.bounds)
        contentView.addSubview(view)
        view.onThumbClick = {
            self.onPostThumbnailClick?(self.post)
        }
        
        return view
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        view.frame = contentView.bounds
    }
    
    init() {
        super.init(style: UITableViewCellStyle.default, reuseIdentifier:PostCell.ID)
    }
    
    var post : Post? {
        willSet {
            post?.thumbnail?.watch.remove(watcher: self)
            post?.preview?.watch.remove(watcher: self)
        }
        
        didSet {
            post?.thumbnail?.watch.add(watcher: self)
            post?.preview?.watch.add(watcher: self)
            
            updateUI()
        }
    }
    
    func updateUI() {
        view.titleLabel.text = post?.title ?? ""
        view.authorLabel.text = "Posted by \(post?.author ?? "")"
        view.commentsLabel.text = "\(post?.commentCount ?? 0) comments"
        
        let date = post?.date
        if (nil != date) {
            let parts = Set<Calendar.Component>(arrayLiteral:.hour, .minute, .second)
            let diff = NSCalendar.current.dateComponents(parts, from: date!, to: Date())
            
            if ((nil != diff.hour) && (diff.hour! > 0)) {
                view.dateLabel.text = "\(diff.hour!) hours ago"
            } else if ((nil != diff.minute) && (diff.minute! > 0)) {
                view.dateLabel.text = "\(diff.minute!) minutes ago"
            } else if ((nil != diff.second) && (diff.second! > 0)) {
                view.dateLabel.text = "\(diff.second!) seconds ago"
            }
        }
        
        view.thumbnail.setImage(post?.thumbnail?.image, for:.normal)
        view.setNeedsLayout()
    }
    
    func onChange(_ obj: AnyObject) {
        if (obj === post?.thumbnail) {
            DispatchQueue.main.async {
                self.updateUI()
            }
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
