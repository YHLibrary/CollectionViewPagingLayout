//
//  ScalePageView.swift
//  CollectionViewPagingLayout
//
//  Created by Amir on 28/03/2021.
//  Copyright © 2021 Amir Khorsandi. All rights reserved.
//

import Foundation
import SwiftUI

public struct ScalePageView<ValueType: Identifiable, PageContent: View>: UIViewControllerRepresentable, TransformPageViewProtocol {

    // MARK: Public
    
    
    // MARK: Properties

    public var builder: Builder


    // MARK: Lifecycle

    public init(
        _ data: [ValueType],
        selection: Binding<ValueType.ID?>? = nil,
        @ViewBuilder viewBuilder: @escaping (ValueType, PagingController?) -> PageContent
    ) {
        builder = .init(data: data, pageViewBuilder: viewBuilder, selection: selection)
        builder.modifierData.scaleOptions = .init()
    }
}


public extension ScalePageView {
    func options(_ options: ScaleTransformViewOptions) -> Self {
        builder.modifierData.scaleOptions = options
        return self
    }
    
    func update(_ row: Int) {
        builder.viewController?.update(row)
    }
}
