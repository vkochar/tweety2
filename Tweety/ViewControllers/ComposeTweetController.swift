//
//  ComposeTweetController.swift
//  Tweety
//
//  Created by Varun on 10/1/17.
//  Copyright © 2017 Varun. All rights reserved.
//

import UIKit
import MBProgressHUD

let placeHolderText = "Tweet here..."
let maxCharacter: Int = 140

class ComposeTweetController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var handleLabel: UILabel!
    @IBOutlet weak var tweetView: UITextView!
    @IBOutlet weak var characterCountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImageView.layer.cornerRadius = 4
        
        tweetView.delegate = self
        tweetView.text = placeHolderText
        tweetView.textColor = .lightGray
        tweetView.becomeFirstResponder()
        
        showCurrentUserInfo()
    }
    
    @IBAction func onSend(_ sender: UIBarButtonItem) {
        
        MBProgressHUD.showAdded(to: view, animated: true)
        TwitterApi.sharedInstance.newTweet(tweetMessage: tweetView.text, success: {
            self.dismiss(animated: true, completion: nil)
            let tweet = Tweet(currentUser: User.currentUser!, tweetMessage: self.tweetView.text, createdAt: Date())
            NotificationCenter.default.post(name: newTweet, object: tweet)
            MBProgressHUD.hide(for: self.view, animated: true)
        }) { (error: Error!) in
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    @IBAction func onCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func showCurrentUserInfo() {
        let user = User.currentUser
        profileImageView.setImageWith(user!.profileUrl!)
        nameLabel.text = user?.name
        
        if let handle = user?.screenname {
            handleLabel.text = "@\(handle)"
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
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        // Set cursor to the beginning when placeholder is set
        if textView.textColor == .lightGray {
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        }
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // Removing the placeholder
        if textView.textColor == .lightGray && text.characters.count > 0 {
            textView.text = ""
            textView.textColor = .black
        }
        
        return (textView.text?.utf16.count ?? 0) + text.utf16.count - range.length <= maxCharacter
    }
    
    func textViewDidChange(_ textView: UITextView) {
        // Setting the placeholder if text is empty
        if textView.text.isEmpty {
            textView.text = placeHolderText
            textView.textColor = .lightGray
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        }
        
        let count = textView.text?.utf16.count ?? 0
        characterCountLabel.text = "\(maxCharacter - count)"
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        // Set cursor to the beginning if placeholder is set
        let firstPosition = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        
        // Do not change position recursively
        if textView.textColor == .lightGray && textView.selectedTextRange != firstPosition {
            textView.selectedTextRange = firstPosition
        }
    }
}
