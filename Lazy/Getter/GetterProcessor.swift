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
        let processors:[GetterGenerator] = [ObjcGetter(),SwiftGetter()]
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
