//
//  MCABaseViewController.swift
//  GitRepo
//
//  Created by Yan Saraev on 2/13/16.
//  Copyright © 2016 matcodes. All rights reserved.
//

import UIKit

struct MCASegueIdentifier {
  static let FromListToRepository = "MCASeguePushFromListToRepository"
}

class MCABaseViewController: UIViewController {
  var pagination: MCAPaginationModel? {
    didSet {
      dispatch_async(dispatch_get_main_queue(), {
        self.prevPageButton?.enabled = self.pagination?.previousPage != nil
        self.nextPageButton?.enabled = self.pagination?.nextPage != nil
      })
    }
  }
  
  @IBOutlet weak var nextPageButton:UIBarButtonItem?
  @IBOutlet weak var prevPageButton:UIBarButtonItem?

  
  @IBAction func nextPage(sender:AnyObject) {
    
  }
  
  @IBAction func previousPage(sender:AnyObject) {
  
  }
}
