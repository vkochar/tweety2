//
//  MenuViewController.swift
//  Tweety
//
//  Created by Varun on 10/3/17.
//  Copyright © 2017 Varun. All rights reserved.
//

import UIKit

protocol MenuViewControllerDelegate: NSObjectProtocol {
    func menuViewController(_ menuViewContrller: MenuViewController, didTapNavigationItem item: NavItem)
}

enum NavItem {
    case PROFILE
    case TIMELINE
    case MENTIONS
}

class MenuViewController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileBackgroundImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var handleLabel: UILabel!
    
    weak var delegate: MenuViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2
        if let user = User.currentUser {
            profileImageView.setImageWith(user.profileUrl!)
            nameLabel.text = user.name
            handleLabel.text = "@\(user.screenname!)"
            
            if let profileBackgroundImageUrl = user.profileBackgroundUrl {
                profileBackgroundImageView.setImageWith(profileBackgroundImageUrl)
            }
        }
    }
    
    @IBAction func didTapProfile(_ sender: UIButton) {
        delegate?.menuViewController(self, didTapNavigationItem: .PROFILE)
    }
    
    @IBAction func didTapTimeline(_ sender: UIButton) {
        delegate?.menuViewController(self, didTapNavigationItem: .TIMELINE)
    }
    
    @IBAction func didTapMentions(_ sender: UIButton) {
        delegate?.menuViewController(self, didTapNavigationItem: .MENTIONS)
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
