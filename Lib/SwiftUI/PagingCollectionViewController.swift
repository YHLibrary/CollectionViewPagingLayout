//
//  PagingCollectionViewController.swift
//  CollectionViewPagingLayout
//
//  Created by Amir on 28/03/2021.
//  Copyright © 2021 Amir Khorsandi. All rights reserved.
//

import UIKit
import SwiftUI

public protocol PagingController {
    func update(_ currentIndex: Int)
}

public class PagingCollectionViewController<ValueType: Identifiable, PageContent: View>: UIViewController,
    UICollectionViewDataSource,
    CollectionViewPagingLayoutDelegate,
    UICollectionViewDelegate,
    UIScrollViewDelegate,
    PagingController {

    // MARK: Properties

    var modifierData: PagingCollectionViewModifierData?
    var pageViewBuilder: ((ValueType, CGFloat) -> PageContent)!
    var onCurrentPageChanged: ((Int) -> Void)?

    private var collectionView: UICollectionView!
    private var list: [ValueType] = []
    private let layout = CollectionViewPagingLayout()


    // MARK: UIViewController

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupCollectionView()
    }


    // MARK: Public functions

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        list.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: PagingCollectionViewCell<ValueType, PageContent> = collectionView.dequeueReusableCellClass(for: indexPath, reuseIdentifier: "cell")
        cell.update(value: list[indexPath.row], index: indexPath, parent: self)
        print("indexPath: \(indexPath.row)")
        return cell
    }

    public func onCurrentPageChanged(layout: CollectionViewPagingLayout, currentPage: Int) {
        onCurrentPageChanged?(currentPage)
    }

    public func update(_ currentIndex: Int) {
        guard currentIndex < self.list.count else {
            return
        }
        let indexPath = IndexPath(row: currentIndex, section: 0)
        if let cell = collectionView.cellForItem(at: indexPath) as? PagingCollectionViewCell<ValueType, PageContent> {
            cell.update(value: list[indexPath.row], index: indexPath, parent: self)
        }
        
    }
    
    // MARK: Internal functions

    func update(list: [ValueType], currentIndex: Int?) {
        var needsUpdate = false
        
        if let self = self as? PagingCollectionViewControllerEquatableList {
            needsUpdate = !self.isListSame(as: list)
        } else {
            let oldIds = self.list.map(\.id)
            needsUpdate = list.map(\.id) != oldIds
        }
        self.list = list
        if needsUpdate {
            collectionView?.reloadData()
            layout.invalidateLayoutInBatchUpdate(invalidateOffset: true)
        }
        let index = currentIndex ?? layout.currentPage
        if index < list.count {
            guard index != layout.currentPage else { return }
            view.isUserInteractionEnabled = false
            layout.setCurrentPage(index) { [weak view] in
                view?.isUserInteractionEnabled = true
            }
        } else {
            layout.invalidateLayoutInBatchUpdate()
        }
    }

    // MARK: UICollectionViewDelegate

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        modifierData?.onTapPage?(indexPath.row)

        if modifierData?.goToSelectedPage ?? true {
            (collectionView.collectionViewLayout as? CollectionViewPagingLayout)?.setCurrentPage(indexPath.row)
        }
    }


    // MARK: Private functions
    
    private func setupCollectionView() {
        collectionView = UICollectionView(
            frame: view.frame,
            collectionViewLayout: layout
        )
        layout.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.registerClass(PagingCollectionViewCell<ValueType, PageContent>.self, reuseIdentifier: "cell")
        collectionView.dataSource = self
        view.fill(with: collectionView)
        layout.numberOfVisibleItems = modifierData?.numberOfVisibleItems
        layout.scrollDirection = modifierData?.scrollDirection ?? layout.scrollDirection
        layout.defaultAnimator = modifierData?.animator
        layout.transparentAttributeWhenCellNotLoaded = modifierData?.transparentAttributeWhenCellNotLoaded ?? layout.transparentAttributeWhenCellNotLoaded
        collectionView.delegate = self

        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isPagingEnabled = true
        modifierData?.collectionViewProperties.forEach { property in
            if let keyPath: WritableKeyPath<UICollectionView, Bool> = property.getKey(),
               let value: Bool = property.getValue() {
                collectionView[keyPath: keyPath] = value
            }
            if let keyPath: WritableKeyPath<UICollectionView, UIView> = property.getKey(),
               let value: UIView = property.getValue() {
                collectionView[keyPath: keyPath] = value
            }
            if let keyPath: WritableKeyPath<UICollectionView, UIColor> = property.getKey(),
               let value: UIColor = property.getValue() {
                collectionView[keyPath: keyPath] = value
            }
            if let keyPath: WritableKeyPath<UICollectionView, UIScrollView.ContentInsetAdjustmentBehavior> = property.getKey(),
               let value: UIScrollView.ContentInsetAdjustmentBehavior = property.getValue() {
                collectionView[keyPath: keyPath] = value
            }
            if let keyPath: WritableKeyPath<UICollectionView, UIEdgeInsets> = property.getKey(),
               let value: UIEdgeInsets = property.getValue() {
                collectionView[keyPath: keyPath] = value
            }
            if let keyPath: WritableKeyPath<UICollectionView, CGFloat> = property.getKey(),
               let value: CGFloat = property.getValue() {
                collectionView[keyPath: keyPath] = value
            }
            if let keyPath: WritableKeyPath<UICollectionView, CGSize> = property.getKey(),
               let value: CGSize = property.getValue() {
                collectionView[keyPath: keyPath] = value
            }
        }
    }


}

private protocol PagingCollectionViewControllerEquatableList {
    func isListSame<T>(as list: [T]) -> Bool
}

extension PagingCollectionViewController: PagingCollectionViewControllerEquatableList where ValueType: Equatable {
    func isListSame<T>(as list: [T]) -> Bool {
        self.list == (list as? [ValueType])
    }
}

private extension UICollectionView {
    func registerClass<T: UICollectionViewCell>(_ cellType: T.Type, reuseIdentifier: String = T.reuseIdentifier) {
        register(cellType, forCellWithReuseIdentifier: reuseIdentifier)
    }

    func dequeueReusableCellClass<T: UICollectionViewCell>(for indexPath: IndexPath, type: T.Type? = nil, reuseIdentifier: String = T.reuseIdentifier) -> T {
        (dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? T)!
    }
}


private extension UICollectionViewCell {
    static var reuseIdentifier: String {
        String(describing: self)
    }
}
