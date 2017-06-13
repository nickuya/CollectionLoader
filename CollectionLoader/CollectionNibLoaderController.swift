//
//  CollectionNibLoaderController.swift
//  CollectionLoader
//
//  Created by Nick Kuyakanon on 6/6/17.
//  Copyright © 2017 Oinkist. All rights reserved.
//

import Foundation
import ViewMapper

open class CollectionNibLoaderController<V: ViewMappable, E: DataLoaderEngine>: CollectionViewMapperController<NibCellMapperAdapter<V>, E> {
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  public init(nib: UINib, dataLoader: DataLoader<E> = DataLoader<E>(dataLoaderEngine: E()), initializer: ((NibCellMapperAdapter<V>) -> Void)? = nil) {
    super.init(cellAdapter: NibCellMapperAdapter(nib: nib, initializer: initializer), dataLoader: dataLoader)
  }
  
  public init (nibName: String, dataLoader: DataLoader<E> = DataLoader<E>(dataLoaderEngine: E()), initializer: ((NibCellMapperAdapter<V>) -> Void)? = nil) {
    super.init(cellAdapter: NibCellMapperAdapter(nibName: nibName, initializer: initializer), dataLoader: dataLoader)
  }
}
