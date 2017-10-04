//
//  User.swift
//  Tweety
//
//  Created by Varun on 9/28/17.
//  Copyright © 2017 Varun. All rights reserved.
//

import Foundation

class User: Codable {
    
    var name: String?
    var screenname: String?
    var profileUrl: URL?
    var tagline: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case screenname = "screen_name"
        case profileUrl = "profile_image_url_https"
        case tagline = "description"
    }
    
    class func fromJSON(response: Any)-> User {
        let json = try! JSONSerialization.data(withJSONObject: response, options: JSONSerialization.WritingOptions(rawValue: 0))
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss Z y"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        let user = try! decoder.decode(User.self, from: json)
        return user
    }
    
    static var _currentUser: User?
    class var currentUser: User? {
        get {
            if (_currentUser == nil) {
                let defaults = UserDefaults.standard
                let userData = defaults.object(forKey: "currentUserData") as? Data
                
                if let userData = userData {
                    let decoder = JSONDecoder()
                    _currentUser = try! decoder.decode(User.self, from: userData)
                }
            }
            return _currentUser
        }
        set(user) {
            let defaults = UserDefaults.standard
            
            if let user = user {
                let jsonEncoder = JSONEncoder()
                let data = try! jsonEncoder.encode(user)
                defaults.set(data, forKey: "currentUserData")
            } else {
                defaults.removeObject(forKey: "currentUserData")
            }
            _currentUser = nil
            defaults.synchronize()
        }
    }
}

