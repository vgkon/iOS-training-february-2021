//
//  FavouriteRequestBody.swift
//  iOSMovieApp
//
//  Created by Vassilis Konstantakopoulos on 9/3/21.
//

import Foundation

struct FavouriteRequestBody: Encodable {
    let mediaType : String
    let mediaId: Int
    let favorite: Bool
}

struct FavouriteResponseBody: Decodable {
    let success: Bool
}
