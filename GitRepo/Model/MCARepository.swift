//
//  MCARepository.swift
//  GitRepo
//
//  Created by Yan Saraev on 2/14/16.
//  Copyright © 2016 matcodes. All rights reserved.
//

import UIKit
import Octokit
import RequestKit

class MCARepository: Repository {
  var contributorsURL: String?
  var issuesURL:String?
  
  override init(_ json: [String : AnyObject]) {
    super.init(json)
    contributorsURL = json["contributors_url"] as? String
    let parts = (json["issues_url"] as? String)?.componentsSeparatedByString("{")
    if parts != nil {
      issuesURL = parts![0]
    }
  }
  
}
