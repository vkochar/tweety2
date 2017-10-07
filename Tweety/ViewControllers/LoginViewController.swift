//
//  LoginViewController.swift
//  Tweety
//
//  Created by Varun on 9/26/17.
//  Copyright © 2017 Varun. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onLoginButton(_ sender: Any) {
        TwitterApi.sharedInstance.login(success: {
            print("Logged in")
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let hamburgerNavigationController = storyboard.instantiateViewController(withIdentifier: "hamburgerNavigationController") as! UINavigationController
            let hamburgerViewController = hamburgerNavigationController.topViewController as! HamburgerViewController
            let menuViewController = storyboard.instantiateViewController(withIdentifier: "menuViewController") as! MenuViewController
            menuViewController.delegate = hamburgerViewController
            hamburgerViewController.menuViewController = menuViewController
            
            self.present(hamburgerNavigationController, animated: true, completion: nil)
            
        }) { (error) in
            print(error.localizedDescription)
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
