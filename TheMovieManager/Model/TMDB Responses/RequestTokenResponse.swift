//
//  RequestTokenResponse.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//"success": true,
//"expires_at": "2016-08-26 17:04:39 UTC",
//"request_token": "ff5c7eeb5a8870efe3cd7fc5c282cffd26800ecd"

import Foundation

struct RequestTokenResponse: Codable {
    let success: Bool
    let expiresAt: String
    let requestToken: String
    
    enum CodingKeys: String, CodingKey {
        case success
        case expiresAt = "expires_at"
        case requestToken = "request_token"
    }
}
