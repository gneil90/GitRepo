//
//  MCAGitClient.swift
//  GitRepo
//
//  Created by Yan Saraev on 2/13/16.
//  Copyright © 2016 matcodes. All rights reserved.
//

import Foundation
import UIKit
import Octokit
import RequestKit

let gitErrorDomain = "com.mca_gitClient.swift"

struct MCAGitClientConstant {
  static let ClientId = "ed4b2b43fae991826163"
  static let ClientSecret = "f57ab6b2a49488260d46a0d2a6f91885c5085299"
  
  static let DefaultItemsPerPage = 20
}


class MCAGitClient: NSObject {
  static let sharedClient = MCAGitClient()
  
  let config = OAuthConfiguration(token: MCAGitClientConstant.ClientId, secret: MCAGitClientConstant.ClientSecret, scopes: ["repo", "read:org"])

  func authorize() {
    config.authenticate()
  }
  
  func searchRepository(language: String, perPage:Int, page:Int, completion: (response: Response<MCASearchModel>, paginationModel: MCAPaginationModel?) -> Void) {

    let router = MCASearchRouter.SearchLanguage(config, language, String(perPage), String(page))
    router.loadJSON([String: AnyObject].self) { json, error, r in
      if let error = error {
        completion(response: Response.Failure(error), paginationModel: nil)
      } else {
        if let json = json {
          let searchModel = MCASearchModel(json)
          let pagination = MCAPaginationModel((r?.allHeaderFields)!)
          completion(response: Response.Success(searchModel), paginationModel: pagination)
        } else {
          let error = NSError(domain: gitErrorDomain, code: r!.statusCode, userInfo: nil)
          completion(response: Response.Failure(error), paginationModel: nil)
        }
      }
    }
  }
  
  func loadContributors(absoluteURL:String, limit:Int, completion: (response: Response<[User]>) -> Void) {
    let router = MCAGitRouter.FetchURL(config, absoluteURL)
    router.loadJSON([AnyObject].self, completion: { json, error, r in
      if let error = error {
        completion(response: Response.Failure(error))
      } else {
        if let json = json {
          var contributors = [User]()
          for userJson in json {
            let user = User(userJson as! [String : AnyObject])
            contributors.append(user)
            
            if contributors.count == limit {
              break;
            }
          }
          completion(response: Response.Success(contributors))
        } else {
          let error = NSError(domain: gitErrorDomain, code: r!.statusCode, userInfo: nil)
          completion(response: Response.Failure(error))

        }
      }
    })
  }
  
  func loadIssues(absoluteURL:String, limit:Int, completion: (response: Response<[MCAIssue]>) -> Void) {
    let router = MCAGitRouter.FetchURL(config, absoluteURL)
    router.loadJSON([AnyObject].self, completion: { json, error, r in
      if let error = error {
        completion(response: Response.Failure(error))
      } else {
        if let json = json {
          var issues = [MCAIssue]()
          for issueJson in json {
            let issue = MCAIssue(issueJson as! [String : AnyObject])
            issues.append(issue)
            
            if issues.count == limit {
              break;
            }
          }
          completion(response: Response.Success(issues))
        } else {
          let error = NSError(domain: gitErrorDomain, code: r!.statusCode, userInfo: nil)
          completion(response: Response.Failure(error))
          
        }
      }
    })
  }
  
  func loadPage(pageURL:String, completion: (response: Response<MCASearchModel>, paginationModel: MCAPaginationModel?) -> Void) {
    let router = MCAGitRouter.FetchURL(config, pageURL)
    router.loadJSON([String: AnyObject].self, completion: { json, error, r in
      if let error = error {
        completion(response: Response.Failure(error), paginationModel: nil)
      } else {
        if let json = json {
          let searchModel = MCASearchModel(json)
          let pagination = MCAPaginationModel((r?.allHeaderFields)!)
          completion(response: Response.Success(searchModel), paginationModel: pagination)
        } else {
          let error = NSError(domain: gitErrorDomain, code: r!.statusCode, userInfo: nil)
          completion(response: Response.Failure(error), paginationModel: nil)
        }
      }
    })
  }
}

enum MCAGitRouter:Router {
  case FetchURL(Configuration, String)
  
  var configuration: Configuration {
    switch self {
    case .FetchURL(let config, _): return config
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
    case .FetchURL(_, _):
      return [:]
    }
  }
  
  var path: String {
    switch self {
    case .FetchURL(_, _):
      return ""
    }
  }
  
  
  var URLRequest: NSURLRequest? {
    switch self {
    case .FetchURL(_, let URLstring):
      return request(URLstring, parameters:params)
    }
  }
  
  func loadJSON<T>(expectedResultType: T.Type, completion: (json: T?, error: ErrorType?, r:NSHTTPURLResponse?) -> Void) {
    if let request = URLRequest {
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

