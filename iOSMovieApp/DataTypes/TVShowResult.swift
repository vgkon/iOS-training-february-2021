//
//  TVShowResults.swift
//  iOSMovieApp
//
//  Created by Vassilis Konstantakopoulos on 5/3/21.
//

import Foundation

struct TVShowResult : Decodable, Hashable, Identifiable {
    let id = UUID().uuidString
    var tvShowId : Int?
    var name : String?
    var overview : String?
    var popularity : Float?
    var posterPath : String?
    var voteAverage : Float?
    var voteCount : Float?
    
    enum CodingKeys: String, CodingKey{
        case name, overview, popularity, posterPath, voteAverage, voteCount
        case tvShowId = "id"
    }
    
}
