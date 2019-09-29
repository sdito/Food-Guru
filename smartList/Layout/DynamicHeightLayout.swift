//
//  DynamicHeightLayout.swift
//  smartList
//
//  Created by Steven Dito on 9/28/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit



protocol DynamicHeightLayoutDelegate {
    func collectionView(collectionView: UICollectionView, heightForItemAtIndexPath indexPath: IndexPath) -> CGFloat
}



class DynamicHeightLayout: UICollectionViewLayout {
    var delegate: DynamicHeightLayoutDelegate!
    var numberOfColumns = 2
    private var cache = [UICollectionViewLayoutAttributes]()
    private var contentHeight: CGFloat = 0
    private var width: CGFloat {
        return collectionView!.bounds.width
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: width, height: contentHeight)
    }
    
    override func prepare() {
        if cache.isEmpty {
            let columnWidth = width / CGFloat(numberOfColumns)
            var xOffset = [CGFloat]()
            for column in 0..<numberOfColumns {
                xOffset.append(CGFloat(column) * columnWidth)
            }
            
            var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
            var column = 0
            for item in 0..<collectionView!.numberOfItems(inSection: 0) {
                let indexPath = IndexPath(item: item, section: 0)
                let height = delegate.collectionView(collectionView: collectionView!, heightForItemAtIndexPath: indexPath)
                let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = frame
                cache.append(attributes)
                contentHeight = max(contentHeight, frame.maxY)
                yOffset[column] = yOffset[column] + height
                if column >= numberOfColumns - 1 {
                    column = 0
                } else {
                    column += 1
                }
                //column = column >= (numberOfColumns - 1) ? 0 : column += 1
            }
        }
    }
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes()]
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
}
