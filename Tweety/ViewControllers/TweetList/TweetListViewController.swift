//
//  TweetListViewController.swift
//  Tweety
//
//  Created by Varun on 10/5/17.
//  Copyright © 2017 Varun. All rights reserved.
//

import UIKit
import MBProgressHUD

let reloadHomeTimeline = Notification.Name("reloadHomeTimeline")
let newTweet = Notification.Name("newTweet")

class TweetListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var refreshControl: UIRefreshControl!
    var tweets:[Tweet] = []
    
    var isLoading = false
    var canLoadMore = true
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init() {
        super.init(nibName: "TweetListViewController", bundle: nil)
    }
    
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
    
    func loadTweets() {
        assert(false, "Please override TweetListController.loadTweets()")
    }
    
    func loadPage(maxId: String) {
        assert(false, "Please override TweetListController.loadPage()")
    }
    
    @objc func didPullToRefresh(_ refreshControl: UIRefreshControl) {
        loadTweets()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    //override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    //}
}

extension TweetListViewController: TweetCellDelegate {
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
        let indexPath = tableView.indexPath(for: tweetCell)
        openReplyTweet(tweet: tweets[indexPath!.row])
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
    
    private func openTweetDetails(tweet: Tweet) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tweetDetailViewController = storyboard.instantiateViewController(withIdentifier: "tweetDetailViewController") as! TweetDetailViewController
        tweetDetailViewController.tweet = tweet
        self.navigationController?.pushViewController(tweetDetailViewController, animated: true)
    }
    
    private func openReplyTweet(tweet: Tweet) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let replyTweetNavigationController = storyboard.instantiateViewController(withIdentifier: "replyTweetNavigationController") as! UINavigationController
        let replyTweetController = replyTweetNavigationController.topViewController as! ReplyTweetViewController
        replyTweetController.tweet = tweet
        present(replyTweetNavigationController, animated: true, completion: nil)
    }
}

extension TweetListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        openTweetDetails(tweet: tweets[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tweetCell", for: indexPath) as! TweetCell
        let tweet = tweets[indexPath.row]
        cell.tweet = tweet
        cell.delegate = self
        
        if ((indexPath.row >= tweets.count - 1) && !isLoading && canLoadMore) {
            isLoading = true
            loadPage(maxId: tweet.tweetId!)
        }
        
        return cell
    }
}

