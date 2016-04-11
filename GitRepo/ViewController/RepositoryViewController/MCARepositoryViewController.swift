//
//  MCARepositoryViewController.swift
//  GitRepo
//
//  Created by Yan Saraev on 2/14/16.
//  Copyright © 2016 matcodes. All rights reserved.
//

import UIKit
import Octokit
import RequestKit

enum MCARepositorySection:Int {
  case Issue
  case Contributor
}

class MCARepositoryViewController: MCABaseViewController, UITableViewDataSource, UITableViewDelegate {
  let userCellReuseIdentifier = "user_cell";
  let issueCellReuseIdentifier = "issue_cell";

  var repository:MCARepository?
  @IBOutlet weak var tableView:UITableView?
  @IBOutlet weak var headerTitle:UILabel?
  
  var dataSource = [[AnyObject]]()
  
  let maximumContributors = 3
  let maximumIssues = 3

  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = repository?.name
    self.headerTitle?.text = repository?.repositoryDescription
    
    if repository?.contributorsURL != nil {
      MCAGitClient.sharedClient.loadContributors(repository!.contributorsURL!, limit: maximumContributors, completion: { (response) in
        switch response {
        case .Success(let contributors):
          if contributors.count > 0 {
            self.dataSource.append(contributors)
            self._reloadOnMainThread()
          }
          break
          
        case .Failure(let error):
          print(error)
        }
      })
    }
    
    if repository?.issuesURL != nil {
      MCAGitClient.sharedClient.loadIssues(repository!.issuesURL!, limit:maximumIssues, completion:  { (response) in
        switch response {
        case .Success(let issues):
          if issues.count > 0 {
            self.dataSource.append(issues)
            self._reloadOnMainThread()
          }
          break
          
        case .Failure(let error):
          print(error)
        }
      })
    }
  }

  //MARK: UITableViewDataSource
  func _reloadOnMainThread() {
    dispatch_async(dispatch_get_main_queue(), {
      self.tableView?.reloadData()
    })
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let innerLayer = dataSource[section]
    return innerLayer.count
  }
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return dataSource.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let innerLayer = dataSource[indexPath.section]
    let isContributor = MCARepositorySection.Contributor.rawValue == sectionType(innerLayer[indexPath.row]).rawValue;
    let cell = tableView.dequeueReusableCellWithIdentifier(isContributor ? userCellReuseIdentifier : issueCellReuseIdentifier);
    if isContributor {
      let user = innerLayer[indexPath.row] as! User
      cell?.textLabel?.text = user.login
      
      if user.avatarURL != nil {
        let url = NSURL(string: user.avatarURL!)
        
        cell?.imageView?.sd_setImageWithURL(url, completed: {(image, error, cacheType, imageURL) in
          cell!.imageView!.image = image
          cell?.setNeedsDisplay()
        })
      } else {
        cell?.imageView?.image = nil
      }
    } else {
      let issue = innerLayer[indexPath.row] as! MCAIssue
      cell?.textLabel?.text = issue.title
      cell?.detailTextLabel?.text = issue.body
    }
    
    return cell!
  }
  
  func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    let innerLayer = dataSource[section]
    let isContributor = MCARepositorySection.Contributor.rawValue == sectionType(innerLayer[0]).rawValue;

    if isContributor {
      return NSLocalizedString("Contributor", comment: "")
    } else {
      return NSLocalizedString("Issue", comment: "")
    }
  }
  
  //MARK: Helpers
  
  func sectionType(entity:AnyObject?) -> MCARepositorySection {
    if entity is MCAIssue {
      return .Issue
    } else {
      return .Contributor
    }
  }
}