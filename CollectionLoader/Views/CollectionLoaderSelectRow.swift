//
//  CollectionLoaderRow.swift
//  CollectionLoader
//
//  Created by Nick Kuyakanon on 3/1/17.
//  Copyright © 2017 Oinkist. All rights reserved.
//

import Foundation
import DataSource
import ViewMapper
import Eureka

public final class CollectionLoaderSelectRow<T: CellMapperAdapter, U: DataLoaderEngine>: SelectorRow<PushSelectorCell<U.T>, CollectionLoaderSelectController<T, U>>, RowType where T.T.T == U.T {
  
  public required init(tag: String?) {
    super.init(tag: tag)
  }
  
  public init(collectionAdapter: TableViewMapperAdapter<T, U>, tag: String? = nil, initializer: ((CollectionLoaderSelectRow) -> Void)? = nil) {
    super.init(tag: tag)
    
    presentationMode = .show(
      controllerProvider: ControllerProvider.callback {
        return CollectionLoaderSelectController(collectionAdapter: collectionAdapter) { _ in
          
        }
      },
      onDismiss: { vc in
        _ = vc.navigationController?.popViewController(animated: true)
      }
    )
    
    displayValueFor = {
      guard let objectId = $0 else { return "" }
      return  objectId.objectId
    }
    
    initializer?(self)
  }
}

public class CollectionLoaderSelectController<T: CellMapperAdapter, U: DataLoaderEngine>: CollectionLoaderController<TableViewMapperAdapter<T, U>>, TypedRowControllerType where T.T.T == U.T {
  public var row: RowOf<U.T>!
  public var onDismissCallback: ((UIViewController) -> ())?
  
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  required public init(collectionAdapter: TableViewMapperAdapter<T, U>, callback: ((UIViewController) -> ())? = nil) {
    super.init(collectionAdapter: collectionAdapter)
    
    collectionAdapter.cellAdapter.onTapCell = { value, _ in
      self.row.value = value
    }
    
    onDismissCallback = callback
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
  }
  
  override func refreshScrollView() {
    super.refreshScrollView()

    if let selectedObject = row.value, let index = dataLoader.rowsToDisplay.index(of: selectedObject), let tableView = scrollView as? UITableView {
      tableView.selectRow(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .none)
    }
  }
}



public final class CollectionLoaderSelectMultipleRow<T: CellMapperAdapter, U: DataLoaderEngine>: SelectorRow<PushSelectorCell<Set<U.T>>, CollectionLoaderSelectMultipleController<T, U>>, RowType where T.T.T == U.T {
  
  public required init(tag: String?) {
    super.init(tag: tag)
  }
  
  public init(collectionAdapter: TableViewMapperAdapter<T, U>, tag: String? = nil, initializer: ((CollectionLoaderSelectMultipleRow) -> Void)? = nil) {
    super.init(tag: tag)
    
    presentationMode = .show(
      controllerProvider: ControllerProvider.callback {
        return CollectionLoaderSelectMultipleController(collectionAdapter: collectionAdapter) { _ in
          
        }
      },
      onDismiss: { vc in
        _ = vc.navigationController?.popViewController(animated: true)
      }
    )
    
    displayValueFor = {
      guard let object = $0 else { return "" }
      if object.count == 0 {
        return "None"
      } else if object.count == 1 {
        return object.first?.objectId
      } else {
        return "Multiple"
      }
    }
    
    initializer?(self)
  }
}

public class CollectionLoaderSelectMultipleController<T: CellMapperAdapter, U: DataLoaderEngine>: CollectionLoaderController<TableViewMapperAdapter<T, U>>, TypedRowControllerType where T.T.T == U.T {
  public var row: RowOf<Set<U.T>>!
  public var onDismissCallback: ((UIViewController) -> ())?
  
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  public init(collectionAdapter: TableViewMapperAdapter<T, U>, callback: ((UIViewController) -> ())? = nil) {
    super.init(collectionAdapter: collectionAdapter)
    
    collectionAdapter.cellAdapter.onTapCell = { value, _ in
      var values = self.row.value ?? []
      if values.contains(value) {
        values.remove(value)
      } else {
        values.insert(value)
      }
      
      self.row.value = values
    }
    
    onDismissCallback = callback
  }
  
  override func refreshScrollView() {
    super.refreshScrollView()
    
    if let rows = row.value, let tableView = scrollView as? UITableView, rows.count > 0 {
      for row in rows {
        if let index = dataLoader.rowsToDisplay.index(of: row) {
          tableView.selectRow(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .none)
        }
      }
    }
  }
}