//
//  ViewController.swift
//  RingLabsTest
//
//  Created by Serge Kutny on 1/25/18.
//  Copyright © 2018 skutnii. All rights reserved.
//

import UIKit

class FeedController: UIViewController, UITableViewDataSource, UITableViewDelegate, Observer {
        
    var contentView: UITableView {
        get {
            return view as! UITableView
        }
    }
    
    var posts : [Post] {
        get {
            return Store.global.posts
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = (tableView.dequeueReusableCell(withIdentifier: PostCell.ID) as? PostCell) ?? PostCell()
        let post = posts[indexPath.row]
        cell.post = post
        
        cell.onPostThumbnailClick = {
            [unowned self] post in
            if (nil != post) {
                self.performSegue(withIdentifier: "FullSize", sender: post)
            }
        }
        
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
        
        contentView.reloadData()
        
        Store.global.watch.add(watcher: self)
        fetch()
    }
    
    func onChange(_ object: AnyObject) {
        if (object === Store.global) {
            DispatchQueue.main.async {
                self.contentView.reloadData()
            }
        }
    }
    
    func fetch() {
        _ = Store.global.fetch().rescue {
            error in
            let message = (error as? String) ?? "Unknown error"
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            let dismiss = UIAlertAction(title: "Close", style: .default)
            alert.addAction(dismiss)
            self.present(alert, animated: true, completion: nil)
            
            return nil
        }
    }
    
    var preventLoad = false
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "FullSize") {
            let post = sender as? Post
            let dest = segue.destination as? FullImageController
            dest?.navigationItem.title = post?.title
            dest?.image = post?.preview
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let paths = contentView.indexPathsForVisibleRows
        guard nil != paths else {
            return
        }
        
        var row = 0
        for path in paths! {
            if (path.row > row) {
                row = path.row
            }
        }
        
        if (row == posts.count - 1) {
            fetch()
        }
    }
}

