//
//  MovieItemCell2.swift
//  lab2FilmInfo
//
//  Created by Adrian Chizhevskyi on 21.12.2020.
//

import UIKit

import Kingfisher
import MarkerKit
import CoreData
import UIKit

final class MovieItemCell2: UICollectionViewCell{
    var link: TopFilmsVC?
    private struct Sizes {
        static let posterDefaultWidth: CGFloat = 120
        static let posterDefaultHeight: CGFloat = 200
    }
    private let markFavoriteButton = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
    private let posterImageView = UIImageView(contentMode: .scaleAspectFill)
    private let movieTitleLabel = UILabel(font: .systemFont(ofSize: 17, weight: .semibold), backgroundColor: .white, lines: 1)
    private let releaseDateView = MovieYearReleaseView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        markFavoriteButton.addTarget(self, action: #selector(markFavorite), for: .touchUpInside)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func saveMovie(with id: Int64, completion: @escaping (Result<Bool, Error>) -> ()) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            completion(.failure(CoreDataError.noAppDelegate))
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "MovieEntity", in: managedContext)!
        let movie = NSManagedObject(entity: entity, insertInto: managedContext)
        movie.setValue(id, forKey: "movieId")
        
        do {
            try managedContext.save()
            completion(.success(true))
        } catch {
            completion(.failure(error))
        }
    }
    
    func coreDataContains(id: Int64) -> Bool {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return false
            }
            let managedContext = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MovieEntity")
            let moviesId = try? managedContext.fetch(fetchRequest)
            for data in moviesId as! [NSManagedObject] {
                let value = data.value(forKey: "movieId") as! NSNumber
                if Int(truncating: value) == id {
                    return true
                }
                
            }
            
            return false
        }
    func deleteFromCoreData(id: Int64) {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            let managedContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MovieEntity")
            do {
                let moviesId = try managedContext.fetch(fetchRequest)
                
                for data in moviesId as! [NSManagedObject] {
                    let value = data.value(forKey: "movieId") as! NSNumber
                    if Int(truncating: value) == id {
                        managedContext.delete(data)
                    }
                    
                }
                
                try? managedContext.save()
                
            } catch _ as NSError {
                print("Deleting Error")
            }
        }
    @objc func markFavorite(sender: UIButton!){
        
        if coreDataContains(id: Int64(sender.tag)){
            markFavoriteButton.setImage(UIImage(named: "emptyStar"), for: .normal)
            deleteFromCoreData(id: Int64(sender.tag))
            print("Deleted")
        }
        else{
            markFavoriteButton.setImage(UIImage(named: "fullStar"), for: .normal)
            saveMovie(with: Int64(sender.tag)){ (result) in
                switch result {
                case .success(let finished):
                    if finished {
                        print("Successfully saved")
                        //self.fetch()
                    } else {
                       // Alert.showErrorSomethingWentWrong()
                    }
                case .failure(let _): break
                   // Alert.showError(message: err.localizedDescription)
                }
            }
        }
       
    }
    private func setupViews() {
        contentView.add(subviews: posterImageView, movieTitleLabel, releaseDateView, markFavoriteButton)
    }
    
    private func setupConstraints() {
        posterImageView.mrk.top(to: contentView, attribute: .top, relation: .equal, constant: 50)
        posterImageView.mrk.leading(to: contentView, attribute: .leading, relation: .equal, constant: 0)
        posterImageView.mrk.centerX(to: contentView, relation: .equal, constant: 0)
        posterImageView.mrk.width(Sizes.posterDefaultWidth)
        posterImageView.mrk.height(Sizes.posterDefaultHeight)

        movieTitleLabel.mrk.top(to: posterImageView, attribute: .bottom, relation: .equal, constant: 5)
        releaseDateView.mrk.top(to: movieTitleLabel, attribute: .bottom, relation: .equal, constant: 12)
        releaseDateView.mrk.left(to: contentView, attribute: .left, relation: .equal, constant: 2)
        markFavoriteButton.mrk.left(to: releaseDateView, attribute: .right, relation: .equal, constant: 2)
        markFavoriteButton.mrk.top(to: movieTitleLabel, attribute: .bottom, relation: .equal, constant: -10)
        
    }

    func setup(with movie: Movie) {
        if let path = movie.posterPath, let imageBaseUrl = URL(string: Config.URL.basePoster) {
            let posterPath = imageBaseUrl
                .appendingPathComponent("w300")
                .appendingPathComponent(path)

            posterImageView.kf.indicatorType = .activity
            posterImageView.kf.setImage(
                with: posterPath,
                options: [.transition(.fade(0.2))], completionHandler:  { [weak self] _,_,_,_  in
                    self?.contentView.layoutIfNeeded()
                })
        }
        movieTitleLabel.text    = movie.title
        releaseDateView.setupWith(date: movie.releaseDate)
        self.markFavoriteButton.tag = Int(truncatingIfNeeded: movie.id!)
        if coreDataContains(id: movie.id!){
            markFavoriteButton.setImage(UIImage(named: "fullStar"), for: .normal)
        } else {
            markFavoriteButton.setImage(UIImage(named: "emptyStar"), for: .normal)
        }
    }
    
    override func prepareForReuse() {
        movieTitleLabel.text = ""
        posterImageView.image = nil
        super.prepareForReuse()
    }
}
