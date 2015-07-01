//
//  StoreViewController.swift
//  Today
//
//  Created by James Tang on 1/7/15.
//  Copyright (c) 2015 James Tang. All rights reserved.
//

import UIKit

class StoreViewController: UIViewController {

    @IBOutlet weak var collectionView : UICollectionView!
    @IBOutlet weak var collectionViewLayout : DropInFlowLayout!
    @IBOutlet weak var pageControl: UIPageControl!

    let currencyFormatter = NSNumberFormatter()

    var identifiers : [String] = []
    var displayingIdentifier : String?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.configureCollectionView()
        self.configureDataSource()
        self.configurePageControl()
    }


    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    deinit {    }

    func reloadData() {
        self.collectionView.reloadData()
    }

    // MARK: Action

    // MARK: Private 

    private func configureCollectionView() {
        self.collectionView.registerNib(UINib(nibName: "StoreCell", bundle: nil), forCellWithReuseIdentifier: "storeCell")
        self.collectionViewLayout.itemSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)
    }

    private func configurePageControl() {
        self.pageControl.numberOfPages = self.identifiers.count
    }

    private func configureDataSource() {
        self.identifiers = ["1", "2", "3"]
    }
}

extension StoreViewController : UICollectionViewDataSource {

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return identifiers.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let identifier = identifiers[indexPath.row]

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("storeCell", forIndexPath: indexPath) as! StoreCell

//        cell.descriptionLabel.text = feature.detail
//        cell.titleLabel.text = feature.title
//        cell.imageView.image = UIImage(named: feature.imageName)
//        cell.videoView.videoName = feature.videoName
//        cell.setProductState(self.store.productState(feature.identifier))

        return cell

    }
}

extension StoreViewController : UICollectionViewDelegateFlowLayout {

    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {

        self.collectionViewLayout.dropInItemAtIndexPath(indexPath)
    }

}

extension StoreViewController : UIScrollViewDelegate {

//    func scrollViewDidScroll(scrollView: UIScrollView) {
//        self.pageControl.currentPage = scrollView.page()
//    }

}
