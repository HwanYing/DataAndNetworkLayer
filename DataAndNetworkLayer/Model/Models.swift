//
//  Models.swift
//  DataAndNetworkLayer
//
//  Created by 梁世仪 on 2023/6/5.
//

import Foundation

struct LoginSuccess: Codable {
    let success: Bool?
    let expires_at: String?
    let request_token: String?
}

struct LoginFailed: Codable {
    let success: Bool?
    let statusCode: Int?
    let statusMessage: String?
    
    enum CodingKeys: String, CodingKey {
        case success
        case statusCode = "status_code"
        case statusMessage = "status_message"
    }
}

struct RequestTokenResponse: Codable {
    let success: Bool?
    let expiresAt: String?
    let requestToken: String?
    
    enum CodingKeys: String, CodingKey {
        case success
        case expiresAt = "expires_at"
        case requestToken = "request_token"
    }
}

struct LoginRequest : Codable {
    let username: String
    let password: String
    let request_token: String
}

struct MovieGenreList : Codable {
    let genres: [MovieGenre]
}

struct MovieGenre : Codable {
    let id: Int
    let name: String
}

