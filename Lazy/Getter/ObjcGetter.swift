//
//  ObjcProcessor.swift
//  LazyGetter
//
//  Created by nangezao on 2017/7/12.
//  Copyright © 2017年 Tang,Nan(MAD). All rights reserved.
//

import XcodeKit

struct ObjcGetter:GetterGenerator {
  struct Constant {
    static let ObjcTemplate = """
                              -(ClassName *)replaceMe{
                                  if(!_replaceMe){
                                      _replaceMe = [[ClassName alloc] init];
                                  }
                                  return _replaceMe;
                              }
                              """
    static let PropertyPlaceHolder  = "replaceMe"
    static let ClassNamePlaceHolder = "ClassName"
  }
  
  func getProperty(from lineText:String) -> String {
    return lineText.components(separatedBy: "*").last!
      .components(separatedBy: ";").first!
      .trimmingCharacters(in: .whitespaces)
  }
  
  func getClassName(from lineText:String) -> String{
    return lineText.components(separatedBy: "*").first!
      .components(separatedBy: ")").last!
      .trimmingCharacters(in: .whitespaces)
  }
  
  func getter(forClass className:String, property:String) -> [String] {
    let templete = templeFor(className: className)
    let texts = templete.replacingOccurrences(of: Constant.ClassNamePlaceHolder,with: className)
                        .replacingOccurrences(of: Constant.PropertyPlaceHolder, with: property)
                        .components(separatedBy: .newlines)
    return texts
  }
  
  func getter(from text:String) -> Array<String> {
    let property = getProperty(from: text)
    let className = getClassName(from: text)
    return getter(forClass: className, property: property)
  }
  
  func templeFor(className:String) -> String {
    if let path = Bundle.main.url(forResource: className, withExtension: ".mapper") {
      do{
        let str = try String(contentsOf: path)
        
        if(!str.isEmpty){
          return str
        }
      }catch{
        
      }
    }
    return Constant.ObjcTemplate
  }
}

extension ObjcGetter{
  func generator(text: String) -> Array<String> {
    return getter(from:text)
  }
    
  // better with regex
  func canProcess(text: String) -> Bool {
    return  text.hasPrefix("@property")
  }
  
  func perform(with invocation: XCSourceEditorCommandInvocation) {
    invocation.buffer.selections.forEach { (textRange) in
      guard let textRange = textRange as? XCSourceTextRange else { return }
      
      for line in textRange.start.line ... textRange.end.line{
        
        guard let text = invocation.buffer.lines[line] as? String,canProcess(text: text) else{
          continue
        }
        let texts = generator(text: text)
        if texts.count >= 1{
          let lines = invocation.buffer.lines
          let start = lines.count - 1
          lines.insert(texts, at: IndexSet(integersIn: start ... start + texts.count - 1))
        }
      }
    }
  }
}
