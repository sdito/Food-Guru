//
//  DynamicHeightLayout.swift
//  smartList
//
//  Created by Steven Dito on 9/28/19.
//  Copyright © 2019 Steven Dito. All rights reserved.
//

import UIKit


protocol DynamicHeightLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForTextAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat
}


class DynamicHeightLayout: UICollectionViewLayout {
    var delegate: DynamicHeightLayoutDelegate!
    var numberOfColumns = 2
    var cellPadding: CGFloat = 2
    var headerHeight: CGFloat = 50 //not really used yet probbaly delete
    
    var cache = [UICollectionViewLayoutAttributes]()
    fileprivate var contentHeight: CGFloat = 0
    fileprivate var width: CGFloat {
        get {
            return collectionView!.bounds.width
        }
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: width, height: contentHeight)
    }
    override func prepare() {
        super.prepare()
        cache.removeAll()
        contentHeight = 0
        if cache.isEmpty {
            let columnWidth = width / CGFloat(numberOfColumns)
            var xOffsets = [CGFloat]()
            for column in 0..<numberOfColumns {
                xOffsets.append(CGFloat(column) * columnWidth)
            }
            var yOffsets = [CGFloat](repeating: 0, count: numberOfColumns)
            var column = 0
            
            
            for item in 0..<collectionView!.numberOfItems(inSection: 0) {
                let indexPath = IndexPath(item: item, section: 0)
                let width = columnWidth - (cellPadding * 2)
                let imageHeight = width
                let height = delegate.collectionView(collectionView!, heightForTextAtIndexPath: indexPath, withWidth: width) + imageHeight + (cellPadding * 2)
                
                let frame = CGRect(x: xOffsets[column], y: yOffsets[column], width: width, height: height)
                let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                
                attributes.frame = insetFrame
                cache.append(attributes)
                
                contentHeight = max(contentHeight, frame.maxY)
                yOffsets[column] = yOffsets[column] + height
                column = column >= (numberOfColumns - 1) ? 0 : column + 1
            }
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }
    
//    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
//        let layoutAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, with: indexPath)
//
//        if elementKind == UICollectionView.elementKindSectionHeader {
//            layoutAttributes.frame = CGRect(x: 0.0, y: 0.0, width: width, height: headerHeight)
//            layoutAttributes.zIndex = Int.max - 3
//        }
//
//        return layoutAttributes
//    }
    
}
