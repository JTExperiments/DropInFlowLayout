//
//  StoreCell.swift
//  Today
//
//  Created by James Tang on 1/7/15.
//  Copyright (c) 2015 James Tang. All rights reserved.
//

import UIKit

class StoreCell: UICollectionViewCell {

    @IBOutlet weak var descriptionLabel : UILabel!
    @IBOutlet weak var titleLabel : UILabel!
    @IBOutlet weak var imageView : UIImageView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var purchaseButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var videoView: UIView!

    override func prepareForReuse() {
        super.prepareForReuse()
        self.descriptionLabel.preferredMaxLayoutWidth = self.frame.size.width - 30
    }

    func startLoading() {
        self.loadingIndicator.startAnimating()
        self.purchaseButton.enabled = false
        self.shareButton.enabled = false
    }

    func stopLoading() {
        self.loadingIndicator.stopAnimating()
        self.purchaseButton.enabled = true
        self.shareButton.enabled = true
    }

}
