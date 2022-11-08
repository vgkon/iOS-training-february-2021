//
//  UsersDetails.swift
//  iOSMovieApp
//
//  Created by Vera Sidiropoulou on 3/3/21.
//

import Foundation

struct UsersDetails : Identifiable, Decodable, Hashable {
    
    let id = UUID().uuidString
    var userName : String?
    var location : String?
    var userFullName : String?


    
    enum CodingKeys : String, CodingKey {
        case location = "iso_3166_1"
        case userFullName = "name"
        case userName

    }
}


