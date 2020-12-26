//
//  Config.swift
//  lab2FilmInfo
//
//  Created by Adrian Chizhevskyi on 17.12.2020.
//

import Foundation

/// Constants and static data.
struct Config {

    static let apiKey = "071635fb0b2b71f93557ffd362974c76"
    
    static let maxQueriesHistoryCount = 10

    struct URL {
        static let base = "http://api.themoviedb.org/3"
        static let basePoster = "http://image.tmdb.org/t/p"
    }
    
    
    struct CellIdentifier {
        struct MovieTable {
            static let movieCell = "MovieItemCell"
            static let collectionCell = "CollectionViewCell"
        }
    }
}
