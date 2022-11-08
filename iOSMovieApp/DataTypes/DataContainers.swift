//
//  File.swift
//  iOSMovieApp
//
//  Created by Vassilis Konstantakopoulos on 23/2/21.
//

import Foundation

struct UserCredentials: Encodable, Decodable {
    var username: String = ""
    var password: String = ""
    var requestToken: String = ""
    
    enum CodingKeys : String, CodingKey {
        case username, password
        case requestToken = "request_token"
    }
}

struct api {
    
    public let apiKey = "4e1a0205795e49daf04ab861550103ad"
    
    static let instance = api()
    fileprivate init(){}
}

struct RequestToken : Encodable, Decodable, Hashable, Identifiable {
    
    let id = UUID().uuidString
    public var requestToken: String = ""
    
}

struct AuthenticationCallback: Decodable, Hashable, Identifiable {
    let id = UUID().uuidString
    var authenticationCallback: String?
}

struct SessionId : Decodable, Hashable, Identifiable {
    let id = UUID().uuidString
    var sessionId: String?
}


