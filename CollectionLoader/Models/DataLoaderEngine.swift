//
//  DataLoaderEngine.swift
//  CollectionLoader
//
//  Created by Nick Kuyakanon on 3/1/17.
//  Copyright © 2017 4f Tech. All rights reserved.
//

import Foundation
import PromiseKit
import DataSource

public enum QueryOrder {
  case ascending, descending
}

public protocol DataLoaderEngine {
  associatedtype T: BaseDataModel
  
  var paginate: Bool { get }  
  var firstRow: T? { get set }
  
  var searchKey: String? { get }
  
  var orderByKey: String? { get }
  var orderByLastValue: Any? { get }
  var order: QueryOrder { get }

  var filterFunction: ((T) -> Bool)? { get }
  var sortFunction: ((T, T) -> Bool)? { get }
  
  var queryLimit: Int? { get }
  var skip: Int { get set }

  init()
  
  mutating func promise(forLoadType loadType: DataLoadType, queryString: String?, filters: [Filter]?) -> Promise<[T]>
}


open class BaseDataLoaderEngine<U: BaseDataModel>: NSObject, DataLoaderEngine {
  public typealias T = U

  open var paginate: Bool { return false }
  public var firstRow: U?
  
  open var searchKey: String? { return nil }
  
  open var orderByKey: String? { return nil }
  open var orderByLastValue: Any? { return nil }
  open var order: QueryOrder { return .ascending }
  
  open var filterFunction: ((T) -> Bool)? { return nil }
  open var sortFunction: ((T, T) -> Bool)? { return nil }
  
  open var queryLimit: Int? { return nil }
  public var skip: Int = 0
  
  public required override init() {
    super.init()
  }
  
  open func request(forLoadType loadType: DataLoadType, queryString: String?, filters: [Filter]?) -> FetchRequest {
    let request: FetchRequest = T.fetchRequest()
    
    if let queryString = queryString, let searchKey = searchKey {
      request.whereKey(searchKey, matchesRegex: queryString, modifiers: "i")
    }
    
    request.limit = queryLimit
    
    switch loadType {
    case .clearAndReplace,.replace,.initial:
      if paginate {
        skip = 0
        request.offset = skip
      }
    case .more:
      if paginate {
        request.offset = skip
      }
    case .newRows:
      if let firstOrder = orderByLastValue, let orderByKey = orderByKey {
        switch order {
        case .ascending:
          request.whereKey(orderByKey, lessThan: firstOrder)
        case .descending:
          request.whereKey(orderByKey, greaterThan: firstOrder)
        }
      }
    }
    
    if let orderByKey = orderByKey {
      switch order {
      case .ascending:
        request.orderByAscending(orderByKey)
      case .descending:
        request.orderByDescending(orderByKey)
      }
    }
    
    return request.apply(filters: filters)
  }
  
  open func promiseForFetch(forLoadType loadType: DataLoadType, queryString: String?, filters: [Filter]?) -> Promise<[T]> {
    let request: FetchRequest = self.request(forLoadType: loadType, queryString: queryString, filters: filters)
    return request.fetch()
  }
  
  open func promise(forLoadType loadType: DataLoadType, queryString: String? = nil, filters: [Filter]?) -> Promise<[T]> {
    if loadType == .newRows && orderByLastValue == nil {
      return Promise(value: [])
    }
    
    return Promise<[T]> { fulfill, reject in
      self.promiseForFetch(forLoadType: loadType, queryString: queryString, filters: filters).then { (results: [T]) -> Void in
        if loadType != .more {
          self.firstRow = results.first
        }
        
        if self.paginate {
          if loadType == .more || loadType == .newRows {
            self.skip += results.count
          } else {
            self.skip = results.count
          }
        }
        
        fulfill(results)
      }.catch { error in
        reject(error)
      }
    }
  }
}


open class NestedDataLoaderEngine<T: BaseDataModel, U: BaseDataModel>: BaseDataLoaderEngine<T> {
  public var parentObject: U!
  
  public init(parentObject: U) {
    super.init()
    
    self.parentObject = parentObject
  }
  
  public required init() {
    super.init()
  }
  
  open override func promiseForFetch(forLoadType loadType: DataLoadType, queryString: String?, filters: [Filter]?) -> Promise<[T]> {
    let request: FetchRequest = self.request(forLoadType: loadType, queryString: queryString, filters: filters)
    return T.sharedDataSource.fetch(request: request, forParentObject: parentObject)
  }
}
