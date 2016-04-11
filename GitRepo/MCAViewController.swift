//
//  ViewController.swift
//  GitRepo
//
//  Created by Yan Saraev on 2/13/16.
//  Copyright © 2016 matcodes. All rights reserved.
//

import UIKit
import Octokit
import RequestKit

class MCAViewController: MCABaseViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
  
  let cellReuseIdentifier = "repository_cell";
  
  @IBOutlet weak var searchBar:UISearchBar?
  @IBOutlet weak var tableView:UITableView?
  var searchModel:MCASearchModel?
  
  var dataSource = [MCARepository]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  //MARK: Navigation
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == MCASegueIdentifier.FromListToRepository {
      let destination = segue.destinationViewController as! MCARepositoryViewController
      destination.repository = sender as? MCARepository
    }
  }
  
  //MARK: IBActions
  
  @IBAction override func nextPage(sender:AnyObject?) {
    if pagination?.nextPage != nil {
      getPage(pagination!.nextPage!)
    }
  }
  
  @IBAction override func previousPage(sender:AnyObject?) {
    if pagination?.previousPage != nil {
      getPage(pagination!.previousPage!)
    }
  }
  
  func getPage(pageURL:String) {
    MCAGitClient.sharedClient.loadPage(pageURL, completion: {(response, pagination) in
      switch response {
      case .Success(let newSearchModel):
        self.searchModel = newSearchModel
        self.pagination = pagination
        
        self.reloadRepositories()
        
      case .Failure(let error):
        print(error)
      }
    })
  }

  //MARK: UITableViewDataSource
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataSource.count
  }
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1;
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier);
    let repo = dataSource[indexPath.row]
    cell?.textLabel?.text = repo.name
    cell?.detailTextLabel?.text = repo.repositoryDescription
    
    return cell!
  }
  
  //MARK: UITableViewDelegate
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)

    let repo = dataSource[indexPath.row]
    performSegueWithIdentifier(MCASegueIdentifier.FromListToRepository, sender: repo)
  }
  
  //MARK: UISearchBar delegate
  
  func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    findRepository()
    searchBar.resignFirstResponder()
  }
  
  func isSearchBarInputValid() -> Bool {
    if searchBar!.text != nil {
      if searchBar!.text!.characters.count > 0 {
        return true
      } else {
        return false
      }
    } else {
      return false
    }
  }
  //MARK: Search Logic
  
  func findRepository() {
    if isSearchBarInputValid() {
      MCAGitClient.sharedClient.searchRepository(searchBar!.text!, perPage:MCAGitClientConstant.DefaultItemsPerPage, page:1, completion: {
        (response, pagination) in
        self.pagination = pagination
        switch response {
        case .Success(let newSearchModel):
          self.searchModel = newSearchModel
          self.reloadRepositories()
          
        case .Failure(let error):
          print(error)
          
        }
      })
    } else {
      resetSearch()
    }
  }
  
  func reloadRepositories() {
    self.dataSource.removeAll()
    self.dataSource.appendContentsOf(self.searchModel!.items)
    dispatch_async(dispatch_get_main_queue(), {
      self.tableView?.reloadData()
    })
  }
  
  func resetSearch() {
    self.dataSource.removeAll()
    self.searchModel = nil
    self.pagination = nil
    self.tableView?.reloadData()
  }
}

