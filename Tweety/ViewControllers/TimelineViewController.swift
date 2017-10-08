//
//  TimelineViewController.swift
//  Tweety
//
//  Created by Varun on 10/7/17.
//  Copyright © 2017 Varun. All rights reserved.
//

import UIKit
import MBProgressHUD

class TimelineViewController: TweetListViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Timeline"
        // Do any additional setup after loading the view.
    }
    
    override func loadTweets() {
        TwitterApi.sharedInstance.homeTimeline(nil, sucess: { (tweets) in
            self.tweets = tweets
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
            MBProgressHUD.hide(for: self.view, animated: true)
        }) { (error: Error!) in
            print("\\m/")
        }
    }
    
    override func loadPage(maxId: String) {
        TwitterApi.sharedInstance.homeTimeline(maxId, sucess: { (tweets) in
            self.tweets.append(contentsOf: tweets)
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
            MBProgressHUD.hide(for: self.view, animated: true)
            self.isLoading = false
        }) { (error: Error!) in
            print("\\m/")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
