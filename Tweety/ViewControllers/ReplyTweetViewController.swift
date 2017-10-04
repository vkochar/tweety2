//
//  ReplyTweetViewController.swift
//  Tweety
//
//  Created by Varun on 10/1/17.
//  Copyright © 2017 Varun. All rights reserved.
//

import UIKit
import MBProgressHUD

let replyPlaceHolderText = "Reply here..."

class ReplyTweetViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var replyToLabel: UILabel!
    @IBOutlet weak var replyTextView: UITextView!
    
    var tweet: Tweet!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        replyToLabel.text = "Reply to @\(tweet.user!.screenname!)"
        
        replyTextView.delegate = self
        replyTextView.text = replyPlaceHolderText
        replyTextView.textColor = .lightGray
        replyTextView.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onReply(_ sender: Any) {
        if let text = replyTextView.text {
            
            let tweetAuthor = (tweet?.user?.screenname)!
            let tweetId = tweet?.tweetId!
            let tweetMessage = "@\(tweetAuthor) \(text)"
            
            print("tweetMessage: \(tweetMessage), tweetId: \(tweetId!)")
            
            MBProgressHUD.showAdded(to: self.view, animated: true)
            
            TwitterApi.sharedInstance.reply(tweetMessage: tweetMessage, tweetId: tweetId!, success: {
                MBProgressHUD.hide(for: self.view, animated: true)
                NotificationCenter.default.post(name: reloadHomeTimeline, object: nil)
                self.dismiss(animated: true, completion: nil)
            }, failure: { (error) in
                print("Error during posting a tweet", error)
                MBProgressHUD.hide(for: self.view, animated: true)
            })
        }
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
            textView.text = replyPlaceHolderText
            textView.textColor = .lightGray
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        }
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
