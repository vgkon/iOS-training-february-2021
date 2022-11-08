//
//  NetworkManager.swift
//  SavingData
//
//  Created by Vassilis Konstantakopoulos on 22/2/21.
//

import UIKit

final class NetworkManager {
    
    enum NetworkError: Error {
        case statusIncorrect
        case dataMissing
        case urlMalformed
    }
    
    static let shared = NetworkManager()
    private let session = URLSession.shared
    
    fileprivate init() {
    }
    
    func createURLRequest(from url: URL) -> URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("4e1a0205795e49daf04ab861550103ad", forHTTPHeaderField: "api-key")
        return urlRequest
    }
    
    func createURLRequest(from url: URL, data: Data) -> URLRequest {
        
        var urlRequest = URLRequest(url: url)
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = data
        return urlRequest
    }
    
    @discardableResult
    func download(query: String, dataType: APICallTypes, closure: @escaping ((Result<Data, Error>) -> Void)) -> URLSessionDataTask? {
        
        guard let finalURL = createURL(query: query, dataType: dataType) else{
            closure(.failure(NetworkError.urlMalformed))
            return nil
        }
        
        print(finalURL.absoluteURL)
        
        let task = session.dataTask(with: createURLRequest(from: finalURL)) { data, response, error in
            
            guard error == nil else {
                closure(.failure(error!))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
                closure(.failure(NetworkError.statusIncorrect))
                return
            }
            
            guard let data = data else {
                closure(.failure(NetworkError.dataMissing))
                return
            }
            closure(.success(data))
        }
        
        task.resume()
        
        return task
    }
    
    func post(query: String, dataToPost: Data, dataReturned: APICallTypes, closure: @escaping ((Result<Data, Error>) -> Void)) {
        
        guard let finalURL = createPOSTURL(query: query, dataType: dataReturned) else{
            closure(.failure(NetworkError.urlMalformed))
            return
        }
        
        print(finalURL.absoluteURL)
        let task = session.dataTask(with: createURLRequest(from: finalURL, data: dataToPost)) { data, response, error in
            
            guard error == nil else {
                closure(.failure(error!))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
                closure(.failure(NetworkError.statusIncorrect))
                return
            }
            
            guard let data = data else {
                closure(.failure(NetworkError.dataMissing))
                return
            }
            closure(.success(data))
        }
        
        task.resume()
    }
    
    func createPOSTURL(query: String, dataType: APICallTypes) -> URL?{
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.themoviedb.org"

        if dataType == APICallTypes.validateCredentials {
            
            components.path = "/3/authentication/token/validate_with_login"
            components.queryItems = [
                URLQueryItem(name: "api_key", value: "4e1a0205795e49daf04ab861550103ad")
            ]
        }else if dataType == APICallTypes.requestSessionID {
            
            components.path = "/3/authentication/session/new"
            components.queryItems = [
                URLQueryItem(name: "api_key", value: "4e1a0205795e49daf04ab861550103ad")
            ]
        }else if dataType == .markAsFavourite{
            //https://api.themoviedb.org/3/account/{account_id}/favorite?api_key=4e1a0205795e49daf04ab861550103ad&session_id=171cbe2080772fbb1270b54eafeffce50157272d
            components.path = "/3/account/\(UserDefaults.standard.string(forKey: "accountId")!)/favorite"
            components.queryItems = [
                URLQueryItem(name: "api_key", value: "4e1a0205795e49daf04ab861550103ad"),
                URLQueryItem(name: "session_id", value: UserDefaults.standard.string(forKey: "sessionId"))
            ]
        }
        
        guard let finalURL = components.url else {
            return nil
        }
        
        return finalURL
    }
    func createURL(query: String, dataType: APICallTypes) -> URL?{
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.themoviedb.org"
        
        if dataType == APICallTypes.searchMovie && query != "" {
            components.path = "/3/search/movie"
            components.queryItems = [
                URLQueryItem(name: "api_key", value: "4e1a0205795e49daf04ab861550103ad"),
                URLQueryItem(name: "language", value: "en-US"),
                URLQueryItem(name: "query", value: query)
            ]
        } else if dataType == APICallTypes.popularMovie{
            components.path = "/3/movie/popular"
            components.queryItems = [
                URLQueryItem(name: "api_key", value: "4e1a0205795e49daf04ab861550103ad"),
                URLQueryItem(name: "language", value: "en-US"),
                URLQueryItem(name: "page", value: "1")
            ]
        }else if dataType == APICallTypes.searchTVShow{
            components.path = "/3/search/tv"
            components.queryItems = [
                URLQueryItem(name: "api_key", value: "4e1a0205795e49daf04ab861550103ad"),
                URLQueryItem(name: "language", value: "en-US"),
                URLQueryItem(name: "query", value: query)
            ]
        }else if dataType == APICallTypes.movieDetails{
            components.path = "/3/movie/\(query)"
            components.queryItems = [
                URLQueryItem(name: "api_key", value: "4e1a0205795e49daf04ab861550103ad"),
                URLQueryItem(name: "language", value: "en-US")
            ]
        }else if dataType == APICallTypes.itemImage{
            components.host = "image.tmdb.org"
            components.path = "/t/p/w500\(query)"
        }else if dataType == APICallTypes.backdropImage{
            components.host = "image.tmdb.org"
            components.path = "/t/p/w500\(query)"
        } else if dataType == APICallTypes.requestToken {
            components.path = "/3/authentication/token/new"
            components.queryItems = [
                URLQueryItem(name: "api_key", value: "4e1a0205795e49daf04ab861550103ad")
            ]
        }else if  dataType == APICallTypes.userDetails{
            components.path = "/3/account"
            components.queryItems = [
                URLQueryItem(name: "api_key", value: "4e1a0205795e49daf04ab861550103ad"),
                URLQueryItem (name: "session_id", value: UserDefaults.standard.string(forKey: "sessionId"))
            ]
        }else if dataType == APICallTypes.userFavouriteMovies {
            guard let accountId = UserDefaults.standard.string(forKey: "accountId") else{
                return nil
            }
            components.path = "/3/account/\(accountId)/favorite/movies"
            components.queryItems = [
                URLQueryItem(name: "api_key", value: "4e1a0205795e49daf04ab861550103ad"),
                URLQueryItem(name: "session_id" , value: UserDefaults.standard.string(forKey: "sessionId")),
                URLQueryItem(name: "language", value: "en-US"),
                URLQueryItem (name: "sort_by", value: "created_at.asc"),
                URLQueryItem(name: "page", value: "1")
            ]
        }else if dataType == APICallTypes.userFavouriteTVShows {
            guard let accountId = UserDefaults.standard.string(forKey: "accountId") else{
                return nil
            }
            components.path = "/3/account/\(accountId)/favorite/tv"
            components.queryItems = [
                URLQueryItem(name: "api_key", value: "4e1a0205795e49daf04ab861550103ad"),
                URLQueryItem(name: "session_id" , value: UserDefaults.standard.string(forKey: "sessionId")),
                URLQueryItem(name: "language", value: "en-US"),
                URLQueryItem (name: "sort_by", value: "created_at.asc"),
                URLQueryItem(name: "page", value: "1")
            ]
        }else if dataType == APICallTypes.userRatedMovies{
            guard let accountId = UserDefaults.standard.string(forKey: "accountId") else{
                return nil
            }
            components.path = "/3/account/\(accountId)/rated/movies"
            components.queryItems = [
                URLQueryItem(name: "api_key", value: "4e1a0205795e49daf04ab861550103ad"),
                URLQueryItem(name: "language", value: "en-US"),
                URLQueryItem(name: "session_id" , value: UserDefaults.standard.string(forKey: "sessionId")),
                URLQueryItem (name: "sort_by", value: "created_at.asc"),
                URLQueryItem(name: "page", value: "1")
            ]
        }else if dataType == APICallTypes.popularTVShow{
            //https://api.themoviedb.org/3/tv/popular?api_key=4e1a0205795e49daf04ab861550103ad&language=en-US
            components.path = "/3/tv/popular"
            components.queryItems = [
                URLQueryItem(name: "api_key", value: "4e1a0205795e49daf04ab861550103ad"),
                URLQueryItem(name: "language", value: "en-US")
            ]
        }else if dataType == APICallTypes.upcomingMovieResult{
            //https://api.themoviedb.org/3/movie/upcoming?api_key=4e1a0205795e49daf04ab861550103ad&language=en-US
            components.path = "/3/movie/upcoming"
            components.queryItems = [
                URLQueryItem(name: "api_key", value: "4e1a0205795e49daf04ab861550103ad"),
                URLQueryItem(name: "language", value: "en-US")
            ]
            
        }else if dataType == APICallTypes.avatar{
//            https://www.themoviedb.org/t/p/w64_and_h64_face/bV0s4vStOBj4k8wBL1WmAgjAgsZ.jpg
//            https://themoviedb.org/t/p/w600_and_h600_bestv2/c4inGiPKJ0tKA84qsDPOYK6W1ya.jpg
            components.host = "www.themoviedb.org"
            components.path = "/t/p/w600_and_h600_bestv2\(query)"
            components.queryItems = [
                URLQueryItem(name: "api_key", value: "4e1a0205795e49daf04ab861550103ad")
            ]
            
        }else if dataType == .tVShowDetails{
//            https://api.themoviedb.org/3/tv/134?api_key=4e1a0205795e49daf04ab861550103ad&language=en-US
            components.path = "/3/tv/\(query)"
            components.queryItems = [
                URLQueryItem(name: "api_key", value: "4e1a0205795e49daf04ab861550103ad"),
                URLQueryItem(name: "language", value: "en-US")
            ]
        }
        
        guard let finalURL = components.url else {
            return nil
        }
        
        return finalURL
    }
    
}


