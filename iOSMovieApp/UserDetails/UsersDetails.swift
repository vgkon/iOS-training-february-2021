//
//  UsersDetails.swift
//  iOSMovieApp
//
//  Created by Vera Sidiropoulou on 3/3/21.
//

import Foundation

struct UsersDetails : Identifiable, Decodable, Hashable {
    
    let id = UUID().uuidString
    var username : String?
    var userFullName : String?
    var avatar : Avatar?
    var accountId : Int?
    
    enum CodingKeys : String, CodingKey {
        case userFullName = "name"
        case username, avatar
        case accountId = "id"

    }
}

struct Avatar : Decodable, Hashable {
    let tmdb : Tmdb?
}

struct Tmdb : Decodable, Hashable {
    var avatarPath : String?
}
