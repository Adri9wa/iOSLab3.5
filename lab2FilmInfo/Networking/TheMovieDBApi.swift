//
//  TheMovieDBApi.swift
//  lab2FilmInfo
//
//  Created by Adrian Chizhevskyi on 17.12.2020.
//

import Foundation

import RxSwift

final class TheMovieDBApi {

    let manager: APIManager

    init(manager: APIManager) {
        self.manager = manager
    }

    /// Gets the movies list.
    ///
    /// - Parameter endpoint: Endpoint.
    /// - Returns: Observable of MoviesResponse.
    func searchMovies(_ endpoint: TheMovieDBEndpoint) -> Observable<MoviesResponse> {
        return manager.request(for: endpoint)
            .debug()
            .map(MoviesResponse.parse)
    }

    /// Gets the most popular movies.
    ///
    /// - Parameter endpoint: Endpoint.
    /// - Returns: Observable of MoviesResponse.s
    func upcomingMovies(_ endpoint: TheMovieDBEndpoint) -> Observable<MoviesResponse> {
        return manager.request(for: endpoint)
            .debug()
            .map(MoviesResponse.parse)
    }

    func topRatedMovies(_ endpoint: TheMovieDBEndpoint) -> Observable<MoviesResponse> {
        return manager.request(for: endpoint)
            .debug()
            .map(MoviesResponse.parse)
    }
    /// Gets the movie details.
    ///
    /// - Parameter endpoint: Endpoint.
    /// - Returns: Observable of MovieDetailsResponse.
    func getMovieDetails(_ endpoint: TheMovieDBEndpoint) -> Observable<MovieDetailsResponse> {
        return manager.request(for: endpoint)
            .debug()
            .map(MovieDetailsResponse.parse)
    }
}
