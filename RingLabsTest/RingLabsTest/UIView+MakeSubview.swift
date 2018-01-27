//
//  UIView+MakeSubview.swift
//  RingLabsTest
//
//  Created by Serge Kutny on 1/27/18.
//  Copyright © 2018 skutnii. All rights reserved.
//

import UIKit

extension UIView {

    func makeSubview<V: UIView>() -> V {
        let view = V(frame: .zero)
        self.addSubview(view)
        return view
    }
    

}
