//
//  MovieModel.swift
//  iOSMovieApp
//
//  Created by Vera Sidiropoulou on 27/2/21.
//


import Foundation

struct  MovieDetails: Identifiable, Decodable, Hashable {
    
    let id = UUID().uuidString
    var movieTitle : String?
    var movieDescription :  String?
    var movieId : Int?
    var voteAverage : Float?
    var posterPath : String?
    var releaseDate : Date?
    var genres = [Int : Genre] ()


    
    enum CodingKeys : String, CodingKey {
        case movieId = "id"
        case movieTitle = "title"
        case movieDescription = "overview"
        case releaseDate = "release_date"
        case posterPath, voteAverage , genres
    }
    
}
struct  Genre : Decodable, Hashable {

    var genreId : Int
    var genreName : String

    enum GenreKeys : String, CodingKey {
        case genreId = "id"
        case genreName = "name"
    }
}






