//
//  Tweet.swift
//  Tweety
//
//  Created by Varun on 9/28/17.
//  Copyright © 2017 Varun. All rights reserved.
//

import Foundation

class Tweet: Codable {
    
    var tweetId: String?
    var text: String?
    var timestamp: Date?
    var retweetCount: Int? = 0
    var favoritesCount: Int? = 0
    var user: User?
    var isFavorite: Bool = false
    var retweeted: Bool = false
    
    convenience init(currentUser: User, tweetMessage: String, createdAt: Date) {
        self.init()
        user = currentUser
        text = tweetMessage
        timestamp = createdAt
    }
    
    enum CodingKeys: String, CodingKey {
        case text
        case user
        case retweeted
        case timestamp = "created_at"
        case retweetCount = "retweet_count"
        case favoritesCount = "favorite_count"
        case isFavorite = "favorited"
        case tweetId = "id_str"
    }
    
    class func fromJSON(response: Any)-> Tweet {
        let json = try! JSONSerialization.data(withJSONObject: response, options: JSONSerialization.WritingOptions(rawValue: 0))
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss Z y"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        let tweet = try! decoder.decode(Tweet.self, from: json)
        return tweet
    }
}
