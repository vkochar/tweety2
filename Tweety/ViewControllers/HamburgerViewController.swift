//
//  HamburgerViewController.swift
//  Tweety
//
//  Created by Varun on 10/3/17.
//  Copyright © 2017 Varun. All rights reserved.
//

import UIKit

class HamburgerViewController: UIViewController, MenuViewControllerDelegate {
    
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentViewLeadingConstraint: NSLayoutConstraint!
    
    var timelineViewController: TweetListViewController!
    var profileViewController:TweetListViewController!
    var mentionsViewController: TweetListViewController!
    
    var originalLeadingConstraint: CGFloat!
    
    var menuViewController: UIViewController! {
        didSet {
            view.layoutIfNeeded()
            
            menuViewController.willMove(toParentViewController: self)
            menuView.addSubview(menuViewController.view)
            menuViewController.didMove(toParentViewController: self)
        }
    }
    
    private var activeVC:UIViewController? {
        didSet{
            removeInactiveVC(inactiveVC: oldValue)
            updateActiveVC()
            UIView.animate(withDuration: 0.3) {
                self.contentViewLeadingConstraint.constant = 0
                self.view.layoutIfNeeded()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timelineViewController = TweetListViewController()
        profileViewController = TweetListViewController()
        mentionsViewController = TweetListViewController()
        
        activeVC = timelineViewController
        
    }
    
    func menuViewController(_ menuViewContrller: MenuViewController, didTapNavigationItem item: NavItem) {
        switch item {
        case .PROFILE:
            activeVC = profileViewController
        case .TIMELINE:
            activeVC = timelineViewController
        case .MENTIONS:
            activeVC = mentionsViewController
        }
    }
    
    func removeInactiveVC(inactiveVC:UIViewController? ) {
        inactiveVC?.willMove(toParentViewController: nil)
        inactiveVC?.view.removeFromSuperview()
        inactiveVC?.removeFromParentViewController()
    }
    
    @IBAction func onLogout(_ sender: Any) {
        TwitterApi.sharedInstance.logout()
        NotificationCenter.default.post(name: logoutNotification, object: nil)
    }
    
    func updateActiveVC() {
        if let activeViewController = activeVC {
            // https://developer.apple.com/library/content/featuredarticles/ViewControllerPGforiPhoneOS/ImplementingaContainerViewController.html
            // 1. Call the addChildViewController: method of your container view controller.
            addChildViewController(activeViewController)
            // 2. Add the child’s root view to your container’s view hierarchy.
            contentView.addSubview(activeViewController.view)
            // 3. Add any constraints for managing the size and position of the child’s root view.
            activeViewController.view.frame = contentView.bounds
            // 4. Call the didMoveToParentViewController: method of the child view controller.
            activeViewController.didMove(toParentViewController: self)
        }
    }
   
    @IBAction func onPan(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        let velocity = sender.velocity(in: view)
        
        switch sender.state {
            
        case UIGestureRecognizerState.began:
            originalLeadingConstraint = contentViewLeadingConstraint.constant
            
        case UIGestureRecognizerState.changed:
            contentViewLeadingConstraint.constant = originalLeadingConstraint + translation.x
            
        case UIGestureRecognizerState.ended:
            UIView.animate(withDuration: 0.2, animations: {
                if velocity.x > 0 {
                    self.contentViewLeadingConstraint.constant = self.view.frame.size.width - self.view.frame.size.width/3
                } else {
                    self.contentViewLeadingConstraint.constant = 0
                }
                self.view.layoutIfNeeded()
            })
            
        default:
            print("\(sender.state)")
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
