//
//  Movie.swift
//  iOSMovieApp
//
//  Created by Vassilis Konstantakopoulos on 26/2/21.
//

import Foundation

struct MovieResult: Decodable, Hashable, Identifiable {
    
    let id = UUID().uuidString
    var movieID: Int?
    var movieTitle: String?
    var voteCount: Int?
    var voteAverage: Float?
    var posterPath: String?
    var popularity: Float?
    
    enum CodingKeys: String, CodingKey {
        case movieID = "id"
        case movieTitle = "title"
        case voteAverage
        case posterPath
        case voteCount
        case popularity
    }
}


//gittest
