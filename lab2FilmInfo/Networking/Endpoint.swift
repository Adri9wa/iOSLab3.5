//
//  Endpoint.swift
//  lab2FilmInfo
//
//  Created by Adrian Chizhevskyi on 17.12.2020.
//

import Foundation

protocol Endpoint {
    var path: String { get }
}

typealias SearchMovieParams = (query: String, page: Int)

enum TheMovieDBEndpoint {
    case searchMovies(SearchMovieParams)
    case topRatedMovies(page: Int)
    case getMovieDetails(movieId: Int64)
    case upcomingMovies(page: Int)
    case getFavoriteMovie(movieId: Int64)
}

extension TheMovieDBEndpoint: Endpoint {
    var path: String {
        switch self {
        case let .searchMovies((query: query, page: page)):
            return "\(Config.URL.base)/search/movie?api_key=\(Config.apiKey)&query=\(query)&page=\(page)"
        case let .upcomingMovies(page: page):
            return "\(Config.URL.base)/movie/upcoming?api_key=\(Config.apiKey)&page=\(page)"
            //http://api.themoviedb.org/3/movie/popular?api_key=<<api_key>>
        case let .getMovieDetails(movieId: movieId):
            return "\(Config.URL.base)/movie/\(movieId)?api_key=\(Config.apiKey)&language=en-US"
        case let .topRatedMovies(page: page):
            return "\(Config.URL.base)/movie/top_rated?api_key=\(Config.apiKey)&page=\(page)"//"&sort_by=vote_average.desc"
        case let .getFavoriteMovie(movieId: movieId):
            return "\(Config.URL.base)/movie/\(movieId)?api_key=\(Config.apiKey)"
        //http://api.themoviedb.org/3/movie/top_rated?api_key=<<api_key>>
        //https://api.themoviedb.org/3/movie/529203?api_key=071635fb0b2b71f93557ffd362974c76&language=en-US
        }
    }
}
