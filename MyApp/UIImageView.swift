//
//  UIImageView.swift
//  MyApp
//
//  Created by Oleksandr Kataskin on 20.02.2024.
//

import UIKit
import SDWebImage


extension UIImageView {

    func loadImage(urlString : String) {
        self.sd_setImage(with: URL(string: urlString), placeholderImage: UIImage(named: "placeholder.png"))
    }

}
