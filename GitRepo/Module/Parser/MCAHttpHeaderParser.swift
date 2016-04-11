//
//  MCAHttpHeaderParser.swift
//  GitRepo
//
//  Created by Yan Saraev on 2/14/16.
//  Copyright © 2016 matcodes. All rights reserved.
//

import UIKit

class MCAHttpHeaderParser: NSObject {
  class func parseLinks(link:String) -> [String : String] {
    var links = [String : String]()
    let parts = (link as NSString).componentsSeparatedByString(",")
    
    for part in parts {
      let section = (part as NSString).componentsSeparatedByString(";")
      

      let urlTag = (section[0].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())) as NSString

      let indexStart = urlTag.rangeOfString("<").location
      let indexFinish = urlTag.rangeOfString(">").location
      
      let urlRange = NSMakeRange(indexStart+1, indexFinish-1)
      let url = urlTag.substringWithRange(urlRange)
      

      let nameTag = (section[1].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())).mutableCopy()
      var name = nameTag.stringByReplacingOccurrencesOfString("\"", withString: "")
      name = name.componentsSeparatedByString("=").last!

      links[name] = url
    }
    
    return links
  }
}
