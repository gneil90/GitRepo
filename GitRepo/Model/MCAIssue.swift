//
//  MCAIssue.swift
//  GitRepo
//
//  Created by Yan Saraev on 2/14/16.
//  Copyright © 2016 matcodes. All rights reserved.
//

import UIKit

class MCAIssue: NSObject {
  var id:Int
  var title:String?
  var body:String?
  
  init(_ json: [String : AnyObject]) {
    if let id = json["id"] as? Int {
      self.id = id
      title = json["title"] as? String
      body = json["body"] as? String
    } else {
      id = -1
    }
  }
}
