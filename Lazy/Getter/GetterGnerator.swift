//
//  GetterGnerator.swift
//  LazyGetter
//
//  Created by nangezao on 2017/7/9.
//  Copyright © 2017年 Tang,Nan(MAD). All rights reserved.
//

import Foundation
import XcodeKit

protocol GetterGenerator {
  func canProcess(text:String) -> Bool
  func generator(text:String) -> Array<String>
  func perform(with invocation: XCSourceEditorCommandInvocation)
}

