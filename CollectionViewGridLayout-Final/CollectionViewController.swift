//
//  ViewController.swift
//  CollectionViewGridLayout-Starter
//
//  Created by Vadim Bulavin on 10/1/18.
//  Copyright © 2018 Vadim Bulavin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	@IBOutlet weak var gridCollectionView: UICollectionView! {
		didSet {
			gridCollectionView.bounces = false
		}
	}
    
    @IBOutlet weak var gridLayout: StickyGridCollectionViewLayout! {
        didSet {
			gridLayout.stickyRowsCount = 1
			gridLayout.stickyColumnsCount = 1
        }
    }
}

// MARK: - Collection view data source and delegate methods

extension ViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 100
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 100
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.reuseID, for: indexPath) as? CollectionViewCell else {
            return UICollectionViewCell()
        }

        cell.titleLabel.text = "\(indexPath)"
		cell.backgroundColor = gridLayout.isItemSticky(at: indexPath) ? .groupTableViewBackground : .white

        return cell
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
}
