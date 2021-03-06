//
//  Const.swift
//  CollectionLoader
//
//  Created by Nick Kuyakanon on 5/2/17.
//  Copyright © 2017 Oinkist. All rights reserved.
//

import Foundation

class Const {
  static let searchBarHeight: CGFloat = 44  
  static let topBarHeight: CGFloat = (UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0) + 44
  static let tabBarHeight: CGFloat = 49
  static let fadeDuration: TimeInterval = 0.5
  static let keyboardAnimationDuration: Double = 0.25
}
