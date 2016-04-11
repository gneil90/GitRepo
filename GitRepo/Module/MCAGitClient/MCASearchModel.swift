//
//  SearchResult.swift
//  GitRepo
//
//  Created by Yan Saraev on 2/14/16.
//  Copyright © 2016 matcodes. All rights reserved.
//

import UIKit
import Octokit
import RequestKit

class MCASearchModel: NSObject {
  var total_count:Int64 = 0
  var incompleteResults:Bool = false
  var items = [MCARepository]()
  
  init(_ json: [String: AnyObject]) {
    if let count = json["total_count"] as? Int64 {
      total_count = count 
    }
    
    if let incomplete = json["incomplete_results"] as? Bool {
      incompleteResults = incomplete
    }
    
    if let repos = json["items"] as? [AnyObject] {
      for repositoryInfo in repos {
        let repository = MCARepository(repositoryInfo as! [String:AnyObject]);
        items.append(repository)
      }
    }
  }
}

enum MCASearchRouter:Router {
  case SearchLanguage(Configuration, String, String, String)
  
  var configuration: Configuration {
    switch self {
    case .SearchLanguage(let config, _, _, _): return config
    }
  }
  
  var method: HTTPMethod {
    return .GET
  }
  
  var encoding: HTTPEncoding {
    return .URL
  }
  
  var params: [String: String] {
    switch self {
    case .SearchLanguage(_, let language, let perPage, let page):
      return ["q":"language:\(language)", "per_page": perPage, "page": page, "sort":"stars", "order":"desc"]
    }
  }
  
  var path: String {
    switch self {
    case .SearchLanguage(_, _, _, _):
      return "/search/repositories"
    }
  }
  
  var URLRequest: NSURLRequest? {
    switch self {
    case .SearchLanguage(_, _, _, _):
      return request()
    }
  }
  
  func loadJSON<T>(expectedResultType: T.Type, completion: (json: T?, error: ErrorType?, r:NSHTTPURLResponse?) -> Void) {
    if let request = request() {
      let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, err in
        if let response = response as? NSHTTPURLResponse {
          if response.statusCode != 200 {
            let error = NSError(domain: gitErrorDomain, code: response.statusCode, userInfo: nil)
            completion(json: nil, error: error, r:response)
            return
          }
        }
        
        if let err = err {
          completion(json: nil, error: err, r: nil)
        } else {
          if let data = data {
            do {
              let JSON = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? T
              completion(json: JSON, error: nil, r:response as? NSHTTPURLResponse)
            } catch {
              completion(json: nil, error: error, r: nil)
            }
          }
        }
      }
      task.resume()
    }
  }

}

