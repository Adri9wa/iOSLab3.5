//
//  Dependencies.swift
//  lab2FilmInfo
//
//  Created by Adrian Chizhevskyi on 17.12.2020.
//

import Foundation

final class Dependencies {

    static let shared = Dependencies()

    var api: TheMovieDBApi

    init() {
        let apiManager = APIManager(session: URLSession(configuration: .default))
        self.api = TheMovieDBApi(manager: apiManager)
    }
}
