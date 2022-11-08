//
//  MovieModel.swift
//  iOSMovieApp
//
//  Created by Vera Sidiropoulou on 27/2/21.
//


import Foundation

struct  MovieDetails: Identifiable, Decodable, Hashable {
    
    let id = UUID().uuidString
    var movieId : Int?
    var movieTitle : String?
    var movieDescription :  String?
    var popularity : Float?
    var backdropPath : String?
    var voteAverage : Float?
    var genres : [Genre]?
    var releaseDate : Date?
    var homePage : String?
    var tagline : String?

    enum CodingKeys : String, CodingKey {
        case movieId = "id"
        case movieTitle = "title"
        case movieDescription = "overview"
        case releaseDate = "releaseDate"
        case homePage = "homepage"
        case backdropPath, voteAverage, tagline, genres, popularity
    }
    
}
struct  Genre : Decodable, Hashable {

    var name : String

}
