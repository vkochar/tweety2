//
//  TwitterApi.swift
//  Tweety
//
//  Created by Varun on 9/26/17.
//  Copyright © 2017 Varun. All rights reserved.
//

private let consumerKey = "t2n63JfzYcxJ30yGdrOImk4zQ"
private let consumeerSecret = "IjtIBmV6UTpemTe1TETFwg6Dgw6s34W6YsIRS6SnwSyLTBekpS"

private let baseUrl = "https://api.twitter.com"
private let requestTokenPath = "oauth/request_token"
private let authorizeUrlString = "\(baseUrl)/oauth/authorize"
private let accessTokenPath = "oauth/access_token"

private let userPath = "1.1/account/verify_credentials.json"
private let homeTimelinePath = "1.1/statuses/home_timeline.json"
private let userTimelinePath = "1.1/statuses/user_timeline.json"
private let mentionsTimelinePath = "1.1/statuses/mentions_timeline.json"
private let updatePath = "1.1/statuses/update.json"
private let retweetPath = "1.1/statuses/retweet"
private let unRetweetPath = "1.1/statuses/unretweet"
private let createFavoritePath = "1.1/favorites/create.json"
private let removeFavoritePath = "1.1/favorites/destroy.json"
private let userProfilePath = "1.1/users/show.json"

import Foundation
import BDBOAuth1Manager

class TwitterApi: BDBOAuth1SessionManager {
    
    static let sharedInstance: TwitterApi = TwitterApi(baseURL: URL(string: baseUrl)!, consumerKey: consumerKey, consumerSecret: consumeerSecret)
    
    var loginSuccess: (() -> Void)?
    var loginFailure: ((Error) -> Void)?
    
    func login(success: @escaping () -> Void, failure: @escaping (Error) -> Void) {
        
        loginSuccess = success
        loginFailure = failure
        
        deauthorize()
        fetchRequestToken(withPath: requestTokenPath, method: "GET", callbackURL: URL(string: "tweety://oauth")!, scope: nil, success: { (credential: BDBOAuth1Credential?) in
            print("got request token")
            UIApplication.shared.open(URL(string: "\(authorizeUrlString)?oauth_token=\(credential!.token!)")!)
        }, failure: { (error: Error!) in
            print(error.localizedDescription)
            self.loginFailure?(error)
        })
    }
    
    func handleOpenUrl(url: URL) {
        
        let requestTokenString = url.query!
        let requestToken = BDBOAuth1Credential(queryString: requestTokenString)
        
        fetchAccessToken(withPath: accessTokenPath, method: "POST", requestToken: requestToken, success: { (credential: BDBOAuth1Credential?) in
            print("got access token")
            
            self.currentAccount(success: { (user) in
                User.currentUser = user
                self.loginSuccess?()
            }, failure: { (error) in
                print(error.localizedDescription)
                self.loginFailure?(error)
            })
            
        }, failure: { (error: Error!) in
            print(error.localizedDescription)
            self.loginFailure?(error)
        })
    }
    
    func currentAccount(success: @escaping (User) -> Void, failure: @escaping (Error) -> Void) {
        get(userPath, parameters: nil, progress: nil, success: { (task, response) in
            let user = User.fromJSON(response: response!)
            print("got current user")
            success(user)
        }, failure: { (task, error: Error!) in
            print(error.localizedDescription)
            failure(error)
        })
    }
    
    func getUserProfile(screenName: String, success: @escaping (User) -> Void, failure: @escaping (Error) -> Void) {
        let params = ["screen_name": screenName]
        get(userProfilePath, parameters: params, progress: nil, success: { (task, response) in
            let user = User.fromJSON(response: response!)
            success(user)
        }){ (task, error:Error!) in
            print(error.localizedDescription)
            failure(error)
        }
    }
    
    func homeTimeline(_ maxId: String?, sucess: @escaping ([Tweet]) -> Void, failure: @escaping (Error) -> Void) {
        var params: [String:String] = [:]
        if (maxId != nil) {
            params["max_id"] = maxId
        }
        timeline(homeTimelinePath, params:  params, sucess: sucess, failure: failure)
    }
    
    func mentionsTimeline(_ maxId: String?, sucess: @escaping ([Tweet]) -> Void, failure: @escaping (Error) -> Void) {
        var params: [String:String] = [:]
        if (maxId != nil) {
            params["max_id"] = maxId
        }
        timeline(mentionsTimelinePath, params:  params, sucess: sucess, failure: failure)
    }
    
    func userTimeline(_ screenName: String?, maxId: String?, sucess: @escaping ([Tweet]) -> Void, failure: @escaping (Error) -> Void) {
        var params: [String:String] = [:]
        if (maxId != nil) {
            params["max_id"] = maxId
        }
        if (screenName != nil) {
            params["screen_name"] = screenName
        }
        timeline(userTimelinePath, params:  params, sucess: sucess, failure: failure)
    }
    
    private func timeline(_ path: String, params: [String:String?], sucess: @escaping ([Tweet]) -> Void, failure: @escaping (Error) -> Void) {
        print("Requesting: \(path)")
        get(path, parameters: params, progress: nil, success: { (task, resposne) in
            let dictionaries = resposne as! [NSDictionary]
            var tweets:[Tweet] = []
            print("Got tweets for \(path)")
            dictionaries.forEach{ dictionary in
                let tweet = Tweet.fromJSON(response: dictionary)
                tweets.append(tweet)
            }
            sucess(tweets)
        }, failure: { (task, error: Error!) in
            print(error.localizedDescription)
            failure(error)
        })
    }
    
    private func update(params: Any?, success: @escaping () -> Void, failure: @escaping (Error) -> Void) {
        post(updatePath, parameters: params, progress: nil, success: { (task, response) in
            success()
        }) { (task, error: Error!) in
            print(error.localizedDescription)
            failure(error)
        }
    }
    
    func newTweet(tweetMessage: String, success: @escaping () -> Void, failure: @escaping (Error) -> Void) {
        let params = ["status": tweetMessage]
        update(params: params, success: success, failure: failure)
    }
    
    func reply(tweetMessage: String, tweetId: String, success: @escaping () ->(), failure: @escaping (Error) -> ()) {
        let params = ["status": tweetMessage, "in_reply_to_status_id": tweetId]
        update(params: params, success: success, failure: failure)
    }
    
    func retweet(tweetId: String, success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        let pathWithTweetId = "\(retweetPath)/\(tweetId).json"
        post(pathWithTweetId, parameters: nil, progress: nil, success: { (task, response) in
            success()
        }) { (task, error: Error!) in
            print(error.localizedDescription)
            failure(error)
        }
    }
    
    func unRetweet(tweetId: String, success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        let pathWithTweetId = "\(unRetweetPath)/\(tweetId).json"
        post(pathWithTweetId, parameters: nil, progress: nil, success: { (task, response) in
            success()
        }) { (task, error: Error!) in
            print(error.localizedDescription)
            failure(error)
        }
    }
    
    func createFavorite(tweetId: String, success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        let params = ["id": tweetId]
        post(createFavoritePath, parameters: params, progress: nil, success: { (task, response) in
            success()
        }) { (task, error: Error!) in
            print(error.localizedDescription)
            failure(error)
        }
    }
    
    func removeFavorite(tweetId: String, success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        let params = ["id": tweetId]
        post(removeFavoritePath, parameters: params, progress: nil, success: { (task, response) in
            success()
        }) { (task, error: Error!) in
            print(error.localizedDescription)
            failure(error)
        }
    }
    
    func logout() {
        deauthorize()
        User.currentUser = nil
    }
}
