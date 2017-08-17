//
//  ViewController.swift
//  UIExpandableCollectionView
//
//  Created by Nathan Tannar on 8/17/17.
//  Copyright © 2017 Nathan Tannar. All rights reserved.
//

import UIKit

class ViewController: UICollectionViewController {
    
    // MARK: - Properties
    
    open var layout: UICollectionViewFlowLayout? {
        get {
            return collectionViewLayout as? UICollectionViewFlowLayout
        }
    }
    
    let defaultCellId = "defaultCellId"
    let defaultFooterId = "defaultFooterId"
    let defaultHeaderId = "defaultHeaderId"
    
    // MARK: - Initialization
    
    public init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: defaultCellId)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 5
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: defaultCellId, for: indexPath)
        cell.backgroundColor = .red
        return cell
    }
    
//    override open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        
//        
//        
//        if kind == UICollectionElementKindSectionHeader {
//            
//            
//        } else if kind == UICollectionElementKindSectionFooter {
//            
//        }
//        
//        reusableView.controller = self
//        
//        return reusableView
//    }
}

