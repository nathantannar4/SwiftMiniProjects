//
//  ViewController.swift
//  UIStretchyBannerView
//
//  Created by Nathan Tannar on 8/10/17.
//  Copyright © 2017 Nathan Tannar. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
   
    let padding: CGFloat = 8.0
    private let cellIdentifier = "UniqueCellIdentifier"
    private let headerIdentifier = "UniqueHeaderIdentifier"
    
    lazy var collectionLayout: UICollectionViewStretchyLayout = { [unowned self] in
        let layout = UICollectionViewStretchyLayout()
        layout.itemSpacing = self.padding
        layout.itemSize = CGSize(width: self.view.bounds.width - (self.padding * 2.0), height: 64.0)
        layout.sectionInset = UIEdgeInsets(top: self.padding, left: self.padding, bottom: 32.0, right: self.padding)
        return layout
    }()
    
    lazy var collectionView: UICollectionView = { [unowned self] in
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: self.collectionLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: self.cellIdentifier)
        collectionView.register(UIStretchyBannerView.self, forSupplementaryViewOfKind: UIStretchyBannerViewKind, withReuseIdentifier: self.headerIdentifier)
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        view.addSubview(collectionView)
        _ = [
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ].map { $0.isActive = true }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionLayout.itemSize = CGSize(width: size.width - (padding * 2.0), height: 64.0)
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
        cell.backgroundColor = UIColor.white
        return cell
    }
    
    func collectionView(_ atcollectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! UIStretchyBannerView
        view.imageView.image = #imageLiteral(resourceName: "Background")
        return view
    }
}
