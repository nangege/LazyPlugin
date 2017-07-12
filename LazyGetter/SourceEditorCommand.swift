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
    
    let processors:[GetterGenerator] = [ObjcProcessor(),SwiftProcessor()]
    var generator:GetterGenerator? = nil
    
    invocation.buffer.selections
      .filter{
        $0 as? XCSourceTextRange != nil
      }
      .map{
        $0 as! XCSourceTextRange
      }
      .forEach { (textRange) in
        
        for line in textRange.start.line ... textRange.end.line{
          guard let text = invocation.buffer.lines[line] as? String else{
            continue
          }
          for processor in processors {
            if processor.canProcess(text: text){
              generator = processor
              break
            }
          }
          if generator != nil{
            break
          }
        }
        generator?.perform(with: invocation)
    }
    completionHandler(nil)
  }
}


