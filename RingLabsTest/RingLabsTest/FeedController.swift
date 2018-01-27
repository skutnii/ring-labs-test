//
//  ViewController.swift
//  RingLabsTest
//
//  Created by Serge Kutny on 1/25/18.
//  Copyright © 2018 skutnii. All rights reserved.
//

import UIKit

class FeedController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var feed : Feed = Feed() {
        didSet {
            DispatchQueue.main.async {
                self.contentView.reloadData()
            }
        }
    }
    
    var contentView: UITableView {
        get {
            return view as! UITableView
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feed.posts.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = (tableView.dequeueReusableCell(withIdentifier: PostCell.ID) as? PostCell) ?? PostCell()
        let post = feed.posts[indexPath.row]
        cell.post = post
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return PostCell.View.Height
    }
    
    override func loadView() {
        let tView = UITableView(frame: CGRect.zero);
        tView.dataSource = self
        tView.delegate = self
        self.view = tView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    var preventLoad = false
    
    override func viewDidAppear(_ animated: Bool) {
        if (preventLoad) {
            return
        }
        
        self.feed = Feed.cached ?? Feed()
        _ = Feed.sync().then {
            [weak self] res in
            let feed = res as? Feed
            if (nil != feed) {
                self?.feed = feed!
            }
            
            return feed
        } .rescue { [weak self] error in
            let message = (error as? String) ?? "Unknown error"
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            let dismiss = UIAlertAction(title: "Close", style: .default)
            alert.addAction(dismiss)
            self?.present(alert, animated: true, completion: nil)
            return nil
        }

        preventLoad = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

