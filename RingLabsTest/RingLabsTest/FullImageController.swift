//
//  FullImageController.swift
//  RingLabsTest
//
//  Created by Serge Kutny on 1/27/18.
//  Copyright © 2018 skutnii. All rights reserved.
//

import UIKit
import Photos

class FullImageController: UIViewController, Observer {
    
    func onChange(_ object: AnyObject) {
        if (object === image) {
            DispatchQueue.main.async {
                self.updateView()
            }
        }
    }
    
    var image: WebImage? {
        willSet {
            image?.watch.remove(watcher: self)
        }
        
        didSet {
            image?.watch.add(watcher: self)
            updateView()
            
            if (nil == image?.content) {
                _ = image?.fetch()
            }
        }
    }
    
    func updateView() {
        let content = image?.content
        contentView.imageView.image = content
        if (nil != content) {
            contentView.spinner.stopAnimating()
            saveButton.isEnabled = true
        } else {
            contentView.spinner.startAnimating()
            saveButton.isEnabled = false
        }
    }
    
    var contentView : FullImageView {
        return view as! FullImageView
    }
    
    override func loadView() {
        view = FullImageView(frame: .zero)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = saveButton

        updateView()
    }
    
    func saveAlert(success: Bool) {
        let alert = UIAlertController(title:"RedditTop",
                                      message:success ? "Saved successfully" : "Save error",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title:"Close", style: .cancel))
        self.present(alert, animated: true)
    }
    
    @objc func onSave(image: UIImage,
                      withError error: NSError?,
                      contextInfo: UnsafeMutableRawPointer) {
        saveAlert(success:(nil == error))
    }
    
    private func doSave() {
        guard let content = image?.content else {
            return
        }
        
        UIImageWriteToSavedPhotosAlbum(content, self, #selector(onSave(image:withError:contextInfo:)), nil)
    }
    
    @objc func save(_ sender: AnyObject) {
        guard nil != image?.content else {
            return
        }
        
        let alert = UIAlertController(title:"RedditTop",
                                      message:"Do you want to save the photo to image library?",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title:"No", style: .cancel))
        alert.addAction(UIAlertAction(title:"Yes", style: .default) {
            _ in
            self.doSave()
        })
        
        present(alert, animated: true)
    }
    
    
    lazy var saveButton : UIBarButtonItem = {
        [unowned self] in
        let item = UIBarButtonItem(title: "Save",  style: .plain, target: self, action: #selector(save(_:)))
        return item
    }()

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    static let Title = "FullImageControllerTitle"
    static let URL = "FullImageControllerURL"
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        
        coder.encode(navigationItem.title, forKey:FullImageController.Title)
        coder.encode(image?.url, forKey:FullImageController.URL)
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        navigationItem.title = coder.decodeObject(forKey: FullImageController.Title) as? String
        let url = coder.decodeObject(forKey: FullImageController.URL) as? URL
        guard nil != url else {
            return
        }
        
        image = WebImage(url!)
    }
    
}
