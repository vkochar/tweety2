//
//  ProfileViewController.swift
//  Tweety
//
//  Created by Varun on 10/8/17.
//  Copyright © 2017 Varun. All rights reserved.
//

import UIKit
import MBProgressHUD

class ProfileViewController: TweetListViewController {

    var user: User?
    
    convenience init(_ user: User) {
        self.init()
        self.user = user
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Profile"
        // Do any additional setup after loading the view.
        let headerView = ProfileView()
        headerView.loadFromXib()
        
        TwitterApi.sharedInstance.getUserProfile(screenName: user!.screenname!, success: { (user) in
            headerView.set(user: user)
            self.tableView.tableHeaderView = headerView
            self.tableView.reloadData()
        }) { (error) in
            print("\\m/")
        }
    }
    
    override func loadTweets() {
        TwitterApi.sharedInstance.userTimeline(nil, maxId: nil, sucess: { (tweets) in
            self.tweets = tweets
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
            MBProgressHUD.hide(for: self.view, animated: true)
        }) { (error: Error!) in
            print("\\m/")
        }
    }
    
    override func loadPage(maxId: String) {
        TwitterApi.sharedInstance.userTimeline(nil, maxId: maxId, sucess: { (tweets) in
            self.tweets.append(contentsOf: tweets)
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
            MBProgressHUD.hide(for: self.view, animated: true)
            self.isLoading = false
            self.canLoadMore = tweets.count >= 20
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
