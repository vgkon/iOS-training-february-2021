//
//  TVShowDetails.swift
//  iOSMovieApp
//
//  Created by Vera Sidiropoulou on 7/3/21.
//

import Foundation


struct TVShowDetails : Decodable, Hashable, Identifiable {

    let id = UUID()
    var tvShowId : Int?
    var name : String?
    var overview : String?
    var popularity : Float?
    var backdropPath : String?
    var voteAverage : Float?
    var genres : [Genre]?
    var status : String?
    var firstAirDate : Date?
    var lastAirDate : Date?
    var homepage : String?
    
    enum CodingKeys: String, CodingKey{
        case name, overview, popularity, backdropPath, voteAverage,  genres, status, homepage
        case tvShowId = "id"
        case firstAirDate
        case lastAirDate
    }
    
}
