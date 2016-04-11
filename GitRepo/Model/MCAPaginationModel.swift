//
//  MCAPagination.swift
//  GitRepo
//
//  Created by Yan Saraev on 2/14/16.
//  Copyright © 2016 matcodes. All rights reserved.
//

import UIKit
import Octokit
import RequestKit

class MCAPaginationModel: NSObject {
  var previousPage:String?
  var nextPage:String?
  
  init(_ headers: [NSObject: AnyObject]) {
    let pageURLs = headers["Link"] as? String
    if pageURLs != nil {
      let links = MCAHttpHeaderParser.parseLinks(pageURLs!)
      for (key, value) in links {
        if key == "next" {
          nextPage = value
        } else if key == "prev" {
          previousPage = value
        } else {
          
        }
      }
    }
  }
}

