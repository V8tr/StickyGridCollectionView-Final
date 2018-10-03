//
//  GridCollectionViewLayout.swift
//  CollectionViewGridLayout-Final
//
//  Created by Vadim Bulavin on 10/1/18.
//  Copyright © 2018 Vadim Bulavin. All rights reserved.
//

import UIKit

// Index Path Section = Row
// Index Path Row (Item) = Column
class StickyGridCollectionViewLayout: UICollectionViewFlowLayout {

    var stickyRowsCount = 0 {
        didSet {
            invalidateLayout()
        }
    }
    
    var stickyColumnsCount = 0 {
        didSet {
            invalidateLayout()
        }
    }

	private var allAttributes: [[UICollectionViewLayoutAttributes]] = []
	private var allSizes: [[CGSize]] = []
	private var contentSize = CGSize.zero

	// MARK: - Collection view flow layout methods

	override func prepare() {
		setupSizesIfNeeded()
		setupAttributesIfNeeded()
		updateStickyItemsPositions()

		let lastSectionAttrs = allAttributes.last!
		let lastItemAttrs = lastSectionAttrs.last!
		let contentHeight = lastItemAttrs.frame.origin.y + lastItemAttrs.frame.height
		let contentWidth = lastItemAttrs.frame.origin.x + lastItemAttrs.frame.width
		contentSize = CGSize(width: contentWidth, height: contentHeight)
	}

    override var collectionViewContentSize: CGSize {
        return self.contentSize
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return allAttributes[indexPath.section][indexPath.row]
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        
        for rowAttrs in allAttributes {
            for itemAttrs in rowAttrs where rect.intersects(itemAttrs.frame) {
				layoutAttributes.append(itemAttrs)
            }
        }
        
        return layoutAttributes
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func invalidateLayout() {
        super.invalidateLayout()
        allAttributes = []
        allSizes = []
    }

	// MARK: - Helpers

	private var rowsCount: Int {
		return collectionView!.numberOfSections
	}

	private func columnsCount(in row: Int) -> Int {
		return collectionView!.numberOfItems(inSection: row)
	}

	func isItemSticky(at indexPath: IndexPath) -> Bool {
		return indexPath.item < stickyColumnsCount || indexPath.section < stickyRowsCount
	}

	private func setupSizesIfNeeded() {
		guard allSizes.isEmpty else {
			return
		}
		for row in 0..<rowsCount {
			var rowSizes: [CGSize] = []
			for col in 0..<columnsCount(in: row) {
				rowSizes.append(size(forRow: row, col: col))
			}
			allSizes.append(rowSizes)
		}
	}

	private func setupAttributesIfNeeded() {
		guard allAttributes.isEmpty else {
			return
		}

		var xOffset: CGFloat = 0
		var yOffset: CGFloat = 0

		for row in 0..<rowsCount {
			var lastItemSize = CGSize()
			var rowAttrs: [UICollectionViewLayoutAttributes] = []
			let interitemSpace = self.interitemSpace(forRow: row)
			xOffset = insets(forRow: row).left

			for col in 0..<columnsCount(in: row) {
				lastItemSize = allSizes[row][col]
				let indexPath = IndexPath(item: col, section: row)

				let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
				attributes.frame = CGRect(x: xOffset, y: yOffset, width: lastItemSize.width, height: lastItemSize.height).integral

				if row < stickyRowsCount && col < stickyColumnsCount {
					attributes.zIndex = ZOrder.staticStikyItem
				} else if row < stickyRowsCount || col < stickyColumnsCount {
					attributes.zIndex = ZOrder.stickyItem
				}

				rowAttrs.append(attributes)

				xOffset += lastItemSize.width + interitemSpace
			}
			yOffset += lastItemSize.height
			allAttributes.append(rowAttrs)
		}
	}

	private func updateStickyItemsPositions() {
		guard collectionView != nil else {
			assertionFailure("Collection view cannot be nil")
			return
		}

		for row in 0..<rowsCount {
			for col in 0..<columnsCount(in: row) {
				let attributes = allAttributes[row][col]

				if row < stickyRowsCount {
					var frame = attributes.frame
					frame.origin.y += collectionView!.contentOffset.y
					attributes.frame = frame
				}

				if col < stickyColumnsCount {
					var frame = attributes.frame
					frame.origin.x += collectionView!.contentOffset.x
					attributes.frame = frame
				}
			}
		}
	}

	// MARK: - Sizing

	func size(forRow row: Int, col: Int) -> CGSize {
		guard let delegate = collectionView?.delegate as? UICollectionViewDelegateFlowLayout else {
			return .zero
		}

		guard let size = delegate.collectionView?(collectionView!, layout: self, sizeForItemAt: IndexPath(item: col, section: row)) else {
			assertionFailure("Implement collectionView(_,layout:,sizeForItemAt: in UICollectionViewDelegateFlowLayout")
			return .zero
		}

		return CGSize(width: floor(size.width), height: floor(size.height))
	}

	func insets(forRow row: Int) -> UIEdgeInsets {
		guard let delegate = collectionView?.delegate as? UICollectionViewDelegateFlowLayout else {
			return .zero
		}
		return delegate.collectionView?(collectionView!, layout: self, insetForSectionAt: row) ?? .zero
	}

	func interitemSpace(forRow row: Int) -> CGFloat {
		guard let delegate = collectionView?.delegate as? UICollectionViewDelegateFlowLayout else {
			return 0.0
		}
		return delegate.collectionView?(collectionView!, layout: self, minimumInteritemSpacingForSectionAt: row) ?? 0.0
	}

	// MARK: - ZOrder

	private enum ZOrder {
		static let stickyItem = 1
		static let staticStikyItem = 2
	}
}
