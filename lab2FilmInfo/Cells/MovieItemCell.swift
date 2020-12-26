//
//  MovieItemCell.swift
//  lab2FilmInfo
//
//  Created by Adrian Chizhevskyi on 17.12.2020.
//

import UIKit

import Kingfisher
import MarkerKit
import CoreData
import UIKit
extension UIView {

    /// Adds the set of subviews to current view.
    ///
    /// - Parameter subviews: The set of subviews.
    func add(subviews: UIView...) {
        subviews.forEach(addSubview)
    }
}
extension UIImageView {
    
    /// Convinience method for initialization with specified content mode.
    ///
    /// - Parameters:
    ///   - image: The inititial image.
    ///   - contentMode: Options to specify how a view adjusts its content when its size changes.
    convenience init(_ image: UIImage? = nil, contentMode: UIView.ContentMode) {
        self.init(image: image)
        self.contentMode = contentMode
    }
}

final class MovieItemCell: UITableViewCell {
    
    
    private struct Sizes {
        static let posterDefaultWidth: CGFloat = 100
        static let posterDefaultHeight: CGFloat = 150
    }
    var link: TopFilmsVC?
    
    
    private let markFavoriteButton = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
    
    private let posterImageView = UIImageView(contentMode: .scaleToFill)
    private let movieTitleLabel = UILabel(font: .systemFont(ofSize: 17, weight: .semibold), backgroundColor: .white, lines: 1)
    private let releaseDateView = MovieYearReleaseView()
    private let ratingBar = RatingBar()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        markFavoriteButton.addTarget(self, action: #selector(markFavorite), for: .touchUpInside)
        setupViews()
        setupConstraints()
    }
    
    @objc func markFavorite(sender: UIButton!){
        link?.someMethod(cell: self)
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
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.add(subviews: posterImageView, movieTitleLabel, ratingBar, releaseDateView, markFavoriteButton)
        
    }
    
    
    private func setupConstraints() {
        //TODO: fix the constraints
       
        posterImageView.mrk.top(to: contentView, attribute: .top, relation: .equal, constant: 5)
        posterImageView.mrk.leading(to: contentView, attribute: .leading, relation: .equal, constant: 30)
        posterImageView.mrk.width(Sizes.posterDefaultWidth)
        posterImageView.mrk.height(Sizes.posterDefaultHeight)

        movieTitleLabel.mrk.top(to: contentView, attribute: .top, relation: .equal, constant: 6)
        movieTitleLabel.mrk.leading(to: posterImageView, attribute: .trailing, relation: .equal, constant: 5)
        ratingBar.mrk.top(to: posterImageView, attribute: .centerY, relation: .equal, constant: -40)
        ratingBar.mrk.leading(to: posterImageView, attribute: .trailing, relation: .equal, constant: 70)

        ratingBar.mrk.width(100)
        ratingBar.mrk.height(100)
        
        releaseDateView.mrk.left(to: posterImageView, attribute: .right, relation: .equal, constant: 12)
        releaseDateView.mrk.bottom(to: contentView, attribute: .bottom, relation: .equal, constant: -6)
        markFavoriteButton.mrk.leading(to: ratingBar, attribute: .trailing, relation: .equal, constant: 20)
        markFavoriteButton.mrk.centerY(to: contentView, relation: .equal, constant: 0)
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
            self.markFavoriteButton.tag = Int(truncatingIfNeeded: movie.id!)
            if coreDataContains(id: movie.id!){
                markFavoriteButton.setImage(UIImage(named: "fullStar"), for: .normal)
            } else {
                markFavoriteButton.setImage(UIImage(named: "emptyStar"), for: .normal)
            }
            
        }
        
        movieTitleLabel.text    = movie.title
        ratingBar.awakeFromNib()
        ratingBar.labelPercentSize = 11
        ratingBar.setProgress(to: movie.rating!/10, withAnimation: false, endProgress: movie.rating!/10)
        releaseDateView.setupWith(date: movie.releaseDate)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.image = nil
        ratingBar.setProgress(to: 0, withAnimation: false, endProgress: 0)
    }
}


