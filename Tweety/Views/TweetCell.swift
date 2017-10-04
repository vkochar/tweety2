//
//  TweetCell.swift
//  Tweety
//
//  Created by Varun on 9/30/17.
//  Copyright © 2017 Varun. All rights reserved.
//

import UIKit
import AFNetworking

protocol TweetCellDelegate: NSObjectProtocol {
    func tweetCell(_ tweetCell: TweetCell, didTapFavorite tweet: Tweet)
    func tweetCell(_ tweetCell: TweetCell, didTapReply tweet: Tweet)
    func tweetCell(_ tweetCell: TweetCell, didTapRetweet tweet: Tweet)
}

class TweetCell: UITableViewCell {

    @IBOutlet weak var retweetedByLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var handleLabel: UILabel!
    @IBOutlet weak var timeSinceTweetLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    
    weak var delegate: TweetCellDelegate?
    
    var tweet: Tweet! {
        didSet {
            
            if let profileUrl = tweet.user?.profileUrl {
                profileImage.setImageWith(profileUrl)
            }
            
            if let handle = tweet.user?.screenname {
                handleLabel.text = "@\(handle)"
            }
            
            nameLabel.text = tweet.user?.name
            statusLabel.text = tweet?.text
            
            timeSinceTweetLabel.text = Date().getTimeDifference(pastDate: tweet.timestamp)
            
            favoriteButton.isSelected = tweet.isFavorite
            retweetButton.isSelected = tweet.retweeted
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImage.layer.cornerRadius = 4
        profileImage.clipsToBounds = true
        
        favoriteButton.setImage(#imageLiteral(resourceName: "favorite"), for: UIControlState.normal)
        favoriteButton.setImage(#imageLiteral(resourceName: "favorite_selected"), for: UIControlState.selected)
        retweetButton.setImage(#imageLiteral(resourceName: "retweet"), for: UIControlState.normal)
        retweetButton.setImage(#imageLiteral(resourceName: "retweet_selected"), for: UIControlState.selected)
    }
    
    @IBAction func onReplyButton(_ sender: UIButton) {
        delegate?.tweetCell(self, didTapReply: tweet)
    }
    
    @IBAction func onRetweetButton(_ sender: UIButton) {
        delegate?.tweetCell(self, didTapRetweet: tweet)
    }
    
    @IBAction func onFavoriteButton(_ sender: UIButton) {
        delegate?.tweetCell(self, didTapFavorite: tweet)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
