//
//  TweetsViewController.swift
//  Tweety
//
//  Created by Varun on 9/29/17.
//  Copyright © 2017 Varun. All rights reserved.
//

import UIKit
import MBProgressHUD

let reloadHomeTimeline = Notification.Name("reloadHomeTimeline")
let newTweet = Notification.Name("newTweet")

class TweetsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var refreshControl: UIRefreshControl!
    var tweets:[Tweet] = []
    
    var isLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 110
        tableView.rowHeight = UITableViewAutomaticDimension
        
        let nib = UINib(nibName: "TweetCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "tweetCell")
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(didPullToRefresh(_:)), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
        MBProgressHUD.showAdded(to: view, animated: true)
        loadTweets()
        
        // Listen to reloadHomeTimeline notificaton
        NotificationCenter.default.addObserver(forName: reloadHomeTimeline, object: nil, queue: OperationQueue.main) { (notification) in
            self.refreshControl.beginRefreshing()
            self.loadTweets()
        }
        
        // Listen to newTweet notificaton
        NotificationCenter.default.addObserver(forName: newTweet, object: nil, queue: OperationQueue.main) { (notification) in
            self.tweets.insert(notification.object as! Tweet, at: 0)
            self.tableView.reloadData()
        }
    }
    
    private func loadTweets() {
        TwitterApi.sharedInstance.homeTimeline(nil, sucess: { (tweets) in
            self.tweets = tweets
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
            MBProgressHUD.hide(for: self.view, animated: true)
        }) { (error: Error!) in
            print("\\m/")
        }
    }
    
    private func loadPage(maxId: String) {
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
    
    @objc func didPullToRefresh(_ refreshControl: UIRefreshControl) {
        loadTweets()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLogout(_ sender: Any) {
        TwitterApi.sharedInstance.logout()
        NotificationCenter.default.post(name: logoutNotification, object: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "tweetDetailSegue" {
            let vc = segue.destination as! TweetDetailViewController
            let tweetCell = sender as! TweetCell
            let row = tableView.indexPath(for: tweetCell)!.row
            vc.tweet = tweets[row]
        } else if segue.identifier == "replySegue" {
            let navigationController = segue.destination as! UINavigationController
            let vc = navigationController.topViewController as! ReplyTweetViewController
            let tweetCell = sender as! TweetCell
            let row = tableView.indexPath(for: tweetCell)!.row
            vc.tweet = tweets[row]
        }
    }
}

extension TweetsViewController: TweetCellDelegate {
    func tweetCell(_ tweetCell: TweetCell, didTapFavorite tweet: Tweet) {
        MBProgressHUD.showAdded(to: view, animated: true)
        if (tweet.isFavorite) {
            TwitterApi.sharedInstance.removeFavorite(tweetId: tweet.tweetId!, success: {
                MBProgressHUD.hide(for: self.view, animated: true)
                self.updateLikes(by: -1, tweet: tweet)
                self.tableView.reloadData()
            }, failure: { (error) in
                MBProgressHUD.hide(for: self.view, animated: true)
            })
        } else {
            TwitterApi.sharedInstance.createFavorite(tweetId: tweet.tweetId!, success: {
                MBProgressHUD.hide(for: self.view, animated: true)
                self.updateLikes(by: 1, tweet: tweet)
                self.tableView.reloadData()
            }, failure: { (error) in
                MBProgressHUD.hide(for: self.view, animated: true)
            })
        }
    }
    
    func tweetCell(_ tweetCell: TweetCell, didTapReply tweet: Tweet) {
        performSegue(withIdentifier: "replySegue", sender: tweetCell)
    }
    
    func tweetCell(_ tweetCell: TweetCell, didTapRetweet tweet: Tweet) {
        MBProgressHUD.showAdded(to: view, animated: true)
        if (tweet.retweeted){
            TwitterApi.sharedInstance.unRetweet(tweetId: tweet.tweetId!, success: {
                MBProgressHUD.hide(for: self.view, animated: true)
                self.updateRetweets(by: -1, tweet: tweet)
                self.tableView.reloadData()
            }) { (error) in
                MBProgressHUD.hide(for: self.view, animated: true)
            }
        } else {
            TwitterApi.sharedInstance.retweet(tweetId: tweet.tweetId!, success: {
                MBProgressHUD.hide(for: self.view, animated: true)
                self.updateRetweets(by: 1, tweet: tweet)
                self.tableView.reloadData()
            }) { (error) in
                MBProgressHUD.hide(for: self.view, animated: true)
            }
        }
    }
    
    private func updateLikes(by number: Int, tweet: Tweet) {
        let favorites = tweet.favoritesCount! + number
        tweet.favoritesCount = favorites
        tweet.isFavorite = !tweet.isFavorite
    }
    
    private func updateRetweets(by number: Int, tweet: Tweet) {
        let retweets = tweet.retweetCount! + number
        tweet.retweetCount = retweets
        tweet.retweeted = !tweet.retweeted
    }
}

extension TweetsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "tweetDetailSegue", sender: tableView.cellForRow(at: indexPath))
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tweetCell", for: indexPath) as! TweetCell
        let tweet = tweets[indexPath.row]
        cell.tweet = tweet
        cell.delegate = self
        
        if ((indexPath.row >= tweets.count - 1) && !isLoading) {
            isLoading = true
            loadPage(maxId: tweet.tweetId!)
        }
        
        return cell
    }
}
