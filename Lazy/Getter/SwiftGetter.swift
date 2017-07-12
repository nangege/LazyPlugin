//
//  SwiftProcessor.swift
//  LazyGetter
//
//  Created by nangezao on 2017/7/10.
//  Copyright © 2017年 Tang,Nan(MAD). All rights reserved.
//

import Foundation
import XcodeKit

struct SwiftGetter {
  
  struct Constant {
    static let SwiftTemplate = """
                               let replaceMe:ClassName = {
                                 let replaceMe = ClassName()
                                 return replaceMe
                               }()
                               """
    static let PropertyPlaceHolder  = "replaceMe"
    static let ClassNamePlaceHolder = "ClassName"
  }
  
  
  func getProperty(from lineText:String) -> String {
    return lineText.components(separatedBy: ":").first!
                   .components(separatedBy: .whitespaces).last!
                   .trimmingCharacters(in: .whitespaces)
  }
  
  func getClassName(from lineText:String) -> String{
    return lineText.components(separatedBy: ":").last!
                   .trimmingCharacters(in: .whitespaces)
                   .trimmingCharacters(in: .newlines)
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
    
    // add line space
    let spaceCount = text.countOfPrefexSpace()
    let prefex = String(repeating: " ", count: spaceCount)
    var getter = self.getter(forClass: className, property: property).map({ prefex + $0})
    
    // replace first line as original text appand "= {", so as to keep access control token
    if getter.count > 0{
        getter[0] = text.replacingOccurrences(of: "\\s+$", with: "", options: .regularExpression) + " = {"
    }
    return getter
  }
  
  func templeFor(className:String) -> String {
    if let path = Bundle.main.url(forResource: className, withExtension: ".swiftmapper") {
      do{
        let str = try String(contentsOf: path)
        
        if(!str.isEmpty){
          return str
        }
      }catch{
        
      }
    }
    return Constant.SwiftTemplate
  }
}

extension SwiftGetter:GetterGenerator{
  
  func generator(text: String) -> Array<String> {
    return getter(from:text)
  }
  
  func canProcess(text: String) -> Bool {
    return  text.contains("let ") || text.contains("var ")
  }
  
  func perform(with invocation: XCSourceEditorCommandInvocation) {
    
    invocation.buffer.selections .forEach { (textRange) in
      guard let textRange = textRange as? XCSourceTextRange else { return }
        
      var allTexts = [String]()
        
      for line in textRange.start.line ... textRange.end.line{
        guard  let text = invocation.buffer.lines[line] as? String else{
          continue
        }
        if canProcess(text: text){
          allTexts.append(contentsOf:generator(text: text))
        }else{
          allTexts.append(text)
        }
      }
      let range = NSMakeRange(textRange.start.line,
                              textRange.end.line - textRange.start.line + 1)
      
      invocation.buffer.lines.replaceObjects(in: range ,withObjectsFrom: allTexts)
    }
  }
}

extension String{
  func countOfPrefexSpace() -> Int{
    var count = 0
    for character in self {
      if character == " "{
        count += 1
      }else{
        break
      }
    }
    return count
  }
}
