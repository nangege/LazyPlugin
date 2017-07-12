//
//  MarcoRefactor.swift
//  Lazy
//
//  Created by Tang,Nan(MAD) on 2017/7/12.
//  Copyright © 2017年 Tang,Nan(MAD). All rights reserved.
//

import Foundation
import XcodeKit

class MacroRefactor:NSObject, XCSourceEditorCommand {
  func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) {
    invocation.buffer.selections.forEach { (textRange) in
      guard let textRange = textRange as? XCSourceTextRange else{ return }
      
      for line in textRange.start.line ... textRange.end.line{
        
        guard let text = invocation.buffer.lines[line] as? String ,canProcess(text: text) else{
          continue
        }
        
        let splitTexts = text.components(separatedBy: .whitespaces)
                             .filter{ $0 != ""}
                             .map{ $0.trimmingCharacters(in: .newlines)}
        
        //  at least define , name , value
        if splitTexts.count < 3 { continue }
        
        let name = splitTexts[1]
        let value = splitTexts[2]
        
        guard let type = typerFor(text: value) else { continue }
        
        var constantStatement = "const static \(type) \(name) = \(value);"
        
        if text.contains("//"), let comment = text.components(separatedBy: "//").last{
            constantStatement = constantStatement + " // \(comment)"
        }
        
        invocation.buffer.lines.replaceObject(at: line, with: constantStatement)
      }
    }
    completionHandler(nil)
  }
  
  func typerFor(text:String) -> String?{
    var valueType:String? = nil
    
    if isObjcString(text: text){
      valueType = "NSString *"
    }else if isFloatValue(text: text){
      valueType = "NSNumber *"
    }
    return valueType
  }
  
  func isObjcString(text:String) -> Bool{
    return text.starts(with: "@\"")
  }
  
  func isFloatValue(text:String) -> Bool{
    let floatValue = (text as NSString).floatValue
    return floatValue != 0
  }
  
  func canProcess(text:String) -> Bool {
    return text.trimmingCharacters(in: .whitespaces).hasPrefix("#define")
  }
}
