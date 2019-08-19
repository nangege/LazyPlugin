//
//  GetterProcessor.swift
//  Lazy
//
//  Created by Tang,Nan(MAD) on 2017/7/12.
//  Copyright © 2017年 Tang,Nan(MAD). All rights reserved.
//

import Foundation
import XcodeKit

class GetterProcessor:NSObject,XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) {
        let processors: [GetterGenerator] = [ObjcGetter(),SwiftGetter()]
        var generator: GetterGenerator? = nil
        
        invocation.buffer.selections.forEach { (textRange) in
          guard let textRange = textRange as? XCSourceTextRange else { return }
          for line in textRange.start.line ... textRange.end.line{
            guard let text = invocation.buffer.lines[line] as? String else{  continue }
            
            // find processor to process
            for processor in processors {
              if processor.canProcess(text: text){
                generator = processor
                break
              }
            }
            if generator != nil{  break }
          }
          generator?.perform(with: invocation)
        }
        completionHandler(nil)
    }
}
