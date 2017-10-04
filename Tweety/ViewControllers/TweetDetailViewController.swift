//
//  TweetDetailViewController.swift
//  Tweety
//
//  Created by Varun on 10/1/17.
//  Copyright © 2017 Varun. All rights reserved.
//

import UIKit
import MBProgressHUD

class TweetDetailViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var handleLabel: UILabel!
    @IBOutlet weak var tweetLabel: UILabel!
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var numberOfRetweetsLabel: UILabel!
    @IBOutlet weak var numberOfLikesLabel: UILabel!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    
    var tweet: Tweet!
    var favorites: Int!
    var retweets: Int!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Tweet"
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        favoriteButton.setImage(#imageLiteral(resourceName: "favorite"), for: UIControlState.normal)
        favoriteButton.setImage(#imageLiteral(resourceName: "favorite_selected"), for: UIControlState.selected)
        
        retweetButton.setImage(#imageLiteral(resourceName: "retweet"), for: UIControlState.normal)
        retweetButton.setImage(#imageLiteral(resourceName: "retweet_selected"), for: UIControlState.selected)
        
        showDetails()
    }
    
    private func showDetails() {
        if let tweetUser = tweet.user {
            if let profileImageUrl = tweetUser.profileUrl {
                profileImageView.setImageWith(profileImageUrl)
            }
            if let name = tweetUser.name {
                nameLabel.text = name
            }
            if let handle = tweetUser.screenname {
                handleLabel.text = handle
            }
        }
        
        tweetLabel.text = tweet.text
        
        favorites = tweet.favoritesCount == nil ? 0 : tweet.favoritesCount!
        numberOfLikesLabel.text = "\(favorites!)"
        
        retweets = tweet.retweetCount == nil ? 0 : tweet.retweetCount!
        numberOfRetweetsLabel.text = "\(retweets!)"
        
        favoriteButton.isSelected = tweet.isFavorite
        retweetButton.isSelected = tweet.retweeted
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy, hh:mm a"
        
        createdAtLabel.text = dateFormatter.string(from: tweet.timestamp!)
    }
    
    @IBAction func onReply(_ sender: Any) {
    }

    @IBAction func onRetweet(_ sender: Any) {
        MBProgressHUD.showAdded(to: view, animated: true)
        if (tweet.retweeted){
            TwitterApi.sharedInstance.unRetweet(tweetId: tweet.tweetId!, success: {
                MBProgressHUD.hide(for: self.view, animated: true)
                self.retweetButton.isSelected = false
                self.tweet.retweeted = false
                self.updateRetweets(by: -1)
            }) { (error) in
                MBProgressHUD.hide(for: self.view, animated: true)
            }
        } else {
            TwitterApi.sharedInstance.retweet(tweetId: tweet.tweetId!, success: {
                MBProgressHUD.hide(for: self.view, animated: true)
                self.retweetButton.isSelected = true
                self.tweet.retweeted = true
                self.updateRetweets(by: 1)
            }) { (error) in
                MBProgressHUD.hide(for: self.view, animated: true)
            }
        }
    }
    
    @IBAction func onFavorite(_ sender: Any) {
        MBProgressHUD.showAdded(to: view, animated: true)
        if (tweet.isFavorite) {
            TwitterApi.sharedInstance.removeFavorite(tweetId: tweet.tweetId!, success: {
                MBProgressHUD.hide(for: self.view, animated: true)
                self.favoriteButton.isSelected = false
                self.tweet.isFavorite = false
                self.updateLikes(by: -1)
            }, failure: { (error) in
                MBProgressHUD.hide(for: self.view, animated: true)
            })
        } else {
            TwitterApi.sharedInstance.createFavorite(tweetId: tweet.tweetId!, success: {
                MBProgressHUD.hide(for: self.view, animated: true)
                self.favoriteButton.isSelected = true
                self.tweet.isFavorite = true
                self.updateLikes(by: 1)
            }, failure: { (error) in
                MBProgressHUD.hide(for: self.view, animated: true)
                //
            })
        }
    }
    
    private func updateLikes(by number: Int) {
        favorites = favorites + number
        tweet.favoritesCount = favorites
        numberOfLikesLabel.text = "\(favorites!)"
    }
    
    private func updateRetweets(by number: Int) {
        retweets = retweets + number
        tweet.retweetCount = retweets
        numberOfRetweetsLabel.text = "\(retweets!)"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navigationController = segue.destination as! UINavigationController
        let vc = navigationController.topViewController as! ReplyTweetViewController
        vc.tweet = tweet
    }
}
