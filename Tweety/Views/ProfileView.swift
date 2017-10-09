//
//  ProfileView.swift
//  Tweety
//
//  Created by Varun on 10/8/17.
//  Copyright © 2017 Varun. All rights reserved.
//

import UIKit

class ProfileView: UIView {
    
    @IBOutlet var view: UIView!
    @IBOutlet weak var profileBackgroundImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var numTweetsLabel: UILabel!
    @IBOutlet weak var numFollowingLabel: UILabel!
    @IBOutlet weak var numFollowersLabel: UILabel!
    @IBOutlet weak var handleLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    func loadFromXib() {
        Bundle.main.loadNibNamed("ProfileView", owner: self, options: nil)
        addSubview(view)
        view.frame = self.bounds
        
        // dont know why this doesn't work
        profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2
    }
    
    func set(user: User) {
        
        profileImageView.setImageWith(user.profileUrl!)
        nameLabel.text = user.name
        handleLabel.text = "@\(user.screenname!)"
        
        if let profileBackgroundImageUrl = user.profileBackgroundUrl {
            profileBackgroundImageView.setImageWith(profileBackgroundImageUrl)
        }
        
        if let profieImageUrl = user.profileUrl {
            profileImageView.setImageWith(profieImageUrl)
        }
      
        numTweetsLabel.text = String(describing: user.tweetsCount ?? 0)
        numFollowersLabel.text = String(describing: user.followersCount ?? 0)
        numFollowingLabel.text = String(describing: user.followingCount ?? 0)
     }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}
