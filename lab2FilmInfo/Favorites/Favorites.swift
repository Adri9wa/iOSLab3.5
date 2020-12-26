//
//  Favorites.swift
//  lab2FilmInfo
//
//  Created by Adrian Chizhevskyi on 22.12.2020.
//

import SwiftUI

class Favorites: ObservableObject{
    //let objectWillChange = ObservableObjectPublisher()
    private var moviesId: Set<Int64>
    private let saveKey = "Favorites"
    init(){
        self.moviesId = []
    }
    
    func contains(_ movie: Movie) -> Bool{
        moviesId.contains(movie.id!)
    }
    
    func add(_ movie: Movie){
        objectWillChange.send()
        moviesId.insert(movie.id!)
        save()
    }
    func remove(_ movie: Movie){
        objectWillChange.send()
        moviesId.remove(movie.id!)
        save()
    }
    
    func save(){
        
    }
    
}
