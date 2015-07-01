//
//  DropInFlowLayout.swift
//  Today
//
//  Created by James Tang on 1/7/15.
//  Copyright (c) 2015 James Tang. All rights reserved.
//

import UIKit

extension Array {
    mutating func replace(items : [T], compareHandler:((current:T, target:T)->Bool)) {
        var reversed = items.reverse()
        var copy = self.map { current -> T in
            for target in reversed {
                if compareHandler(current:current, target: target) {
                    return target
                }
            }
            return current
        }

        self = copy
    }
}

class DropInFlowLayout: UICollectionViewFlowLayout, UIGestureRecognizerDelegate {

    var animator : UIDynamicAnimator!
    var droppingIndexPaths : [NSIndexPath:UIDynamicBehavior] = [:]
    var dropped : [NSIndexPath] = []
    var draggingIndexPath: NSIndexPath?
    var gestureRecognizer : UIPanGestureRecognizer!

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.animator = UIDynamicAnimator(collectionViewLayout: self)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        if let collectionView = self.collectionView {
            self.gestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
            self.gestureRecognizer.delegate = self
            collectionView.addGestureRecognizer(self.gestureRecognizer)
        }
    }
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
        var items = super.layoutAttributesForElementsInRect(rect) as! [UICollectionViewLayoutAttributes]

        let adjusted = items.map { (item) -> UICollectionViewLayoutAttributes in
            return self.layoutAttributesForItemAtIndexPath(item.indexPath)
        }

        items.replace(adjusted, compareHandler: { (current, target) -> Bool in
            return current.indexPath == target.indexPath
        })

        for item in items {
            println("lafeir \(rect), row: \(item.indexPath.row) frame:\(item.frame)) alpha: \(item.alpha), hidden: \(item.hidden)")
        }

        let indexPath = NSIndexPath(forItem: 0, inSection: 0)
        println("visibleCells: \(self.collectionView?.visibleCells())")

        return items
    }

    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        if let attribute = self.animator.layoutAttributesForCellAtIndexPath(indexPath) {
            return attribute
        } else {
            var attribute = super.layoutAttributesForItemAtIndexPath(indexPath)
            if let index = find(self.dropped, indexPath) {
                attribute.center.y += self.collectionView!.frame.size.height
            }
            return attribute
        }
    }

    // MARK: Public

    func dropInItemAtIndexPath(indexPath: NSIndexPath) {
        if let item = self.layoutAttributesForItemAtIndexPath(indexPath), let collectionView = self.collectionView
        {
            var center = item.center
            center.y += collectionView.frame.size.height
            if let index = find(self.dropped, indexPath) {
                self.dropped.removeAtIndex(index)
            }
            self.bounceToCenterForIndexPath(indexPath, fromPosition:center)
        }
    }

    func clearBehaviours() {
        self.droppingIndexPaths = [:]
        self.animator.removeAllBehaviors()
    }

    func clearBehaviourForIndexPath(indexPath: NSIndexPath) {
        if let behaviour = self.droppingIndexPaths[indexPath] {
            self.animator.removeBehavior(behaviour)
            self.droppingIndexPaths[indexPath] = nil
        }
        if let index = find(self.dropped, indexPath) {
            self.dropped.removeAtIndex(index)
        }
    }

    // MARK: UIGestureRecognizerDelegate

    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let pan = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = pan.velocityInView(self.collectionView)
            return fabs(velocity.y) > fabs(velocity.x)
        }
        return true
    }

    // MARK: Action

    func handlePanGesture(gesture: UIPanGestureRecognizer) {

        if let collectionView = self.collectionView {

            let translation = gesture.translationInView(collectionView)
            let location = gesture.locationInView(collectionView)

            if let indexPath = collectionView.indexPathForItemAtPoint(location) ?? self.draggingIndexPath {

                switch (gesture.state) {
                case .Began:

                    self.draggingIndexPath = indexPath

                    if let behavior = self.droppingIndexPaths[indexPath] {
                        self.animator.removeBehavior(behavior)
                    }
                    let item = super.layoutAttributesForItemAtIndexPath(indexPath)

                    let offset = UIOffsetMake(location.x - item.center.x, location.y - item.center.y)
                    let attachment = UIAttachmentBehavior(item: item, offsetFromCenter: offset, attachedToAnchor: location)

                    self.droppingIndexPaths[indexPath] = attachment
                    self.animator.addBehavior(attachment)

                    break
                case .Changed:
                    if let behaviour = self.droppingIndexPaths[indexPath] as? UIAttachmentBehavior {
                        behaviour.anchorPoint = location
                    }
                    break

                case .Ended, .Cancelled:
                    if let behaviour = self.droppingIndexPaths[indexPath] as? UIAttachmentBehavior {

                        let item = super.layoutAttributesForItemAtIndexPath(indexPath)

                        let targetCenter = item.center

                        item.center.x += translation.x
                        item.center.y += translation.y

                        self.animator.removeBehavior(behaviour)

                        let snap = UISnapBehavior(item: item, snapToPoint: targetCenter)
                        item.zIndex = 1

                        self.droppingIndexPaths[indexPath] = snap
                        self.animator.addBehavior(snap)
                    }

                    self.draggingIndexPath = nil

                default: break
                }
            } else {
                println("DropInFlowLayout: something strange! missing NSIndexPath")
            }
        }
    }

    // MARK: Private 

    private func bounceToCenterForIndexPath(indexPath: NSIndexPath, fromPosition position: CGPoint) {

        if let item = self.layoutAttributesForItemAtIndexPath(indexPath), let collectionView = self.collectionView
        {
            let targetCenter = item.center
            if let behavior = self.droppingIndexPaths[indexPath]  {
                return
            }

            item.center = position
            let behaviour = UIAttachmentBehavior(item: item, attachedToAnchor: targetCenter)

            behaviour.length = 0.0
            behaviour.damping = 0.8
            behaviour.frequency = 1.5

            self.droppingIndexPaths[indexPath] = behaviour
            self.animator.addBehavior(behaviour)
        }
    }
}
