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
        
        invocation.buffer.selections
            .filter{
                $0 as? XCSourceTextRange != nil
            }
            .map{
                $0 as! XCSourceTextRange
            }
            .forEach { (textRange) in
                for line in textRange.start.line ... textRange.end.line{
                    
                    if let text = verifyPropertyString(invocation.buffer.lines[line]) {
                      
                      let processor = objcProcessor();
                        
                        let texts = processor.generator(text: text)
                        
                        let lines = invocation.buffer.lines
                        let start = lines.count - 1
                        lines.insert(texts, at: IndexSet(integersIn: start ... start + texts.count - 1))
                    }
                }
        }
        
        completionHandler(nil)
    }
}



func verifyPropertyString(_ origin : Any) -> String? {
    if let text = origin as? String, text.hasPrefix("@property") {
        return text
    }
    return nil
}
