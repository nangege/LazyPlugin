//
//  SourceEditorCommand.swift
//  LazyGetter
//
//  Created by Tang,Nan(MAD) on 2016/12/20.
//  Copyright © 2016年 Tang,Nan(MAD). All rights reserved.
//

import Foundation
import XcodeKit


class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
  func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
    let processorMapper:[String:XCSourceEditorCommand] = ["Getter":GetterProcessor(),
                                                          "MacroRefactor":MacroRefactor()]
    
    if let processor = processorMapper[invocation.commandIdentifier] {
      processor.perform(with: invocation, completionHandler: completionHandler)
    }else{
      completionHandler(nil)
    }
    
  }
}


