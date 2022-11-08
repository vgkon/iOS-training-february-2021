//
//  SearchResults.swift
//  iOSMovieApp
//
//  Created by Vassilis Konstantakopoulos on 26/2/21.
//

import Foundation

class SearchResults<T: Decodable> : Decodable {
    let results: [T]
}

