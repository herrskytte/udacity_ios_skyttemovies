//
//  Login.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//"username": "johnny_appleseed",
//"password": "test123",
//"request_token": "1531f1a558c8357ce8990cf887ff196e8f5402ec"

import Foundation

struct LoginRequest: Codable {
    let username: String
    let password: String
    let requestToken: String
    
    enum CodingKeys: String, CodingKey {
        case username
        case password
        case requestToken = "request_token"
    }
}
