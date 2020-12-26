//
//  TopFilmsVC.swift
//  lab2FilmInfo
//
//  Created by Adrian Chizhevskyi on 21.12.2020.
//

import UIKit
import CoreData
import MarkerKit
import RxSwift

class TopFilmsVC: UIViewController, UITableViewDelegate, UICollectionViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var topRatedLabel: UILabel!
    @IBOutlet weak var upcomingLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    let activityIndicatorView = UIActivityIndicatorView(style: .gray)
    @IBOutlet weak var collectionView: UICollectionView!
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupCollectionView()
        setupTableView()
        setupViewAndConstraints()
        setupActivityIndicator()
        bind()
    }

    func setupTableView() {
        tableView.separatorStyle     = .singleLine
        tableView.estimatedRowHeight = 44.0
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView    = UIView()
        tableView.refreshControl = tableRefreshControl
        tableView.register(MovieItemCell.self, forCellReuseIdentifier: Config.CellIdentifier.MovieTable.movieCell)
    }

    func setupCollectionView(){
        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout{
            flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(MovieItemCell2.self, forCellWithReuseIdentifier: Config.CellIdentifier.MovieTable.collectionCell)
    }
    
    func setupViewAndConstraints() {
    }

    func someMethod(cell: MovieItemCell){
//        print("inside vc")
        let indexPathTapped = tableView.indexPath(for: cell)
        //print(indexPathTapped)
        let tappedMovie = model.movieItem(at: indexPathTapped!)
        print(tappedMovie?.id)
        //self.saveMovie(with: (tappedMovie?.id!)!){ (result) in
          //  switch result {
           // case .success(let finished):
             //   if finished {
                    //print("Successfully saved")
                    //self.fetch()
              //  } else {
                   // Alert.showErrorSomethingWentWrong()
               // }
            //case .failure(let _): break
               // Alert.showError(message: err.localizedDescription)
            //}
        //}
    }
    /*fileprivate func fetch() {
        fetchMovies { (result) in
            switch result {
            case .success(let managedObjects):
                self.name = managedObjects
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let err): break
               // Alert.showError(message: err.localizedDescription)
            }
        }
    }*/
    
    	
    private func setupActivityIndicator() {
        view.addSubview(activityIndicatorView)

        activityIndicatorView.mrk.centerX(to: view)
        activityIndicatorView.mrk.centerY(to: view, relation: .equal, constant: -100)
    }

    func bind() {
        model.inProgress
            .bind(to: activityIndicatorView.rx.isAnimating)
            .disposed(by: disposeBag)

        tableRefreshControl.rx
            .controlEvent(.valueChanged)
            .asObservable()
            .subscribe(onNext: { [weak self] in self?.model.loadNextData.onNext(.fromStart) })
            .disposed(by: disposeBag)
        
        model2.dataRefreshed
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.tableView.refreshControl?.endRefreshing()
                self.collectionView.reloadData()
            }).disposed(by: disposeBag)
        model.dataRefreshed
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.tableView.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            }).disposed(by: disposeBag)

        model.onError
            .subscribe(onNext: { [weak self] message in self?.showError(message: message) })
            .disposed(by: disposeBag)
        model2.onError
            .subscribe(onNext: { [weak self] message in self?.showError(message: message) })
            .disposed(by: disposeBag)
    }

    final func showError(message: String) {
        showAlertController(self, title: "Error", message: message, style: .one("Ok"), handler: nil)
    }

    final func isCanLoadNextData(for scrollView: UIScrollView) -> Bool {
        let currentOffset = scrollView.contentOffset.y

        if scrollView.contentSize.height < scrollView.frame.size.height {
            return false
        }

        let maiximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let deltaOffset = maiximumOffset - currentOffset

        if deltaOffset <= 350 {
            return true
        }

        return false
    }
    private let model = TopFilmsVM()
    private let model2 = TopFilmsVM2()
    private lazy var tableRefreshControl: UIRefreshControl = {
        let rc = UIRefreshControl()
        rc.attributedTitle = NSAttributedString(string: "Pull to refresh")
        return rc
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .always
            navigationController?.navigationBar.prefersLargeTitles = true
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.movies.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Config.CellIdentifier.MovieTable.movieCell, for: indexPath) as! MovieItemCell
        cell.link = self
        if let movieItem = model.movieItem(at: indexPath) {
            cell.setup(with: movieItem)
        }
        return cell
    }
    	
   

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let movieItem = model.movieItem(at: indexPath), let id = movieItem.id else {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        let controller = MovieDetailsVC(movieId: id)
        controller.hidesBottomBarWhenPushed = true
        self.dismiss(animated: true, completion: nil)
        self.present(controller, animated: true, completion: nil)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !model.isPageLoading.value && !model.endOfData.value else { return }
        if isCanLoadNextData(for: scrollView) {
            loadNextData()
        }
        
    }

    private func loadNextData() {
        model.loadNextData.onNext(.continueLoading)
        model2.loadNextData.onNext(.continueLoading)
    }
}

extension TopFilmsVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 200, height: 350)
    }
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Config.CellIdentifier.MovieTable.collectionCell, for: indexPath) as! MovieItemCell2
        let movieItem = model2.movies[indexPath.section]
        
            cell.setup(with: movieItem)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 15.0, bottom: 0, right: 15.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movieItem = model2.movies[indexPath.section]
        guard let id = movieItem.id else { return  }
            collectionView.deselectItem(at: indexPath, animated: true)

        
        let controller = MovieDetailsVC(movieId: id)
        controller.hidesBottomBarWhenPushed = true
        self.dismiss(animated: true, completion: nil)
        self.present(controller, animated: true, completion: nil)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return model2.movies.count
        
    }
    
   
   
}
extension TopFilmsVC{
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
    
    
}
