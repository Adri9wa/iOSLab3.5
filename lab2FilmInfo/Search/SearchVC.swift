//
//  SearchVC.swift
//  lab2FilmInfo
//
//  Created by Adrian Chizhevskyi on 21.12.2020.
//

import UIKit

import MarkerKit
import RxSwift

class SearchVC: UITableViewController {

    @IBOutlet weak var searchContainer: UIView!
    let activityIndicatorView = UIActivityIndicatorView(style: .gray)
    private let model = SearchScreenVM()
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private lazy var emptyDataLabel: UILabel = {
        let label = UILabel(font: .systemFont(ofSize: 14), alignment: .center)
        label.text = "Please type something and tap Search"
        return label
    }()
    
    private var isSearchBarActive = false
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        setupTableView()
        setupViewAndConstraints()
        setupActivityIndicator()
        bind()
    }

    func setupTableView() {
        tableView.separatorStyle     = .singleLine
        tableView.estimatedRowHeight = 44.0
        tableView.tableFooterView    = UIView()
        tableView.register(MovieItemCell.self, forCellReuseIdentifier: Config.CellIdentifier.MovieTable.movieCell)
    }

    func setupViewAndConstraints() {
        

        view.add(subviews: emptyDataLabel)

        setupSearchController()
        setupConstraints()
    }
    private func setupSearchController() {
        
        searchContainer.addSubview(searchController.searchBar)
        searchController.searchBar.delegate = self
        searchController.searchBar.searchBarStyle = .minimal
        
        definesPresentationContext = true
        
        if #available(iOS 11, *) {
            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = false
        } else {
            searchController.searchBar.backgroundColor = .white
            tableView.tableHeaderView = searchController.searchBar
        }
    }
    private func setupConstraints() {
        emptyDataLabel.mrk.centerX(to: view)
        emptyDataLabel.mrk.centerY(to: view, relation: .equal, constant: -100)
        emptyDataLabel.mrk.leading(to: view, attribute: .leading, relation: .equal, constant: 20)
        emptyDataLabel.mrk.trailing(to: view, attribute: .trailing, relation: .equal, constant: -20)
    }
    private func setupActivityIndicator() {
        view.addSubview(activityIndicatorView)

        activityIndicatorView.mrk.centerX(to: view)
        activityIndicatorView.mrk.centerY(to: view, relation: .equal, constant: -100)
    }

    func bind() {
        model.inProgress
            .bind(to: activityIndicatorView.rx.isAnimating)
            .disposed(by: disposeBag)
        
        model.dataRefreshed
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] isEmptyData in
                guard let `self` = self else { return }
                self.emptyDataLabel.isHidden = !isEmptyData
                self.tableView.reloadData()
            }).disposed(by: disposeBag)
        
        model.onError
            .subscribe(onNext: { [weak self] message in self?.showError(message: message) })
            .disposed(by: disposeBag)
    }
    private func tapToSearchMovies(for query: String) {
        searchController.isActive = false
        model.lastQuery = query
        model.loadNextData.onNext(.fromStart)
    }
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !isSearchBarActive && !model.isPageLoading.value && !model.endOfData.value else { return }
        
        if isCanLoadNextData(for: scrollView) {
            loadNextData()
        }
    }
    private func loadNextData() {
        model.loadNextData.onNext(.continueLoading)
    }
    final func showError(message: String) {
        showAlertController(self, title: "Error", message: message, style: .one("Ok"), handler: nil)
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.movies.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isSearchBarActive {
            return 44
        } else {
            return 160
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
            let cell = tableView.dequeueReusableCell(withIdentifier: Config.CellIdentifier.MovieTable.movieCell, for: indexPath) as! MovieItemCell
            if let movieItem = model.movieItem(at: indexPath) {
                cell.setup(with: movieItem)
            }
            return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
            guard let movieItem = model.movieItem(at: indexPath), let id = movieItem.id else {
                tableView.deselectRow(at: indexPath, animated: true)
                return
            }
            let controller = MovieDetailsVC(movieId: id)
            controller.hidesBottomBarWhenPushed = true
            self.dismiss(animated: true, completion: nil)
            self.present(controller, animated: true, completion: nil)
        
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
    
}
extension SearchVC: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        tableView.reloadData()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchString = searchController.searchBar.text {
            tapToSearchMovies(for: searchString)
        }
    }
}
extension UILabel {

    /// Convenient factory method for UILabel declaration.
    ///
    /// - Parameters:
    ///   - font: Font of the label.
    ///   - color: Text color of the label.
    ///   - backgroundColor: Background color of the label.
    ///   - lines: Number of lines.
    ///   - alignment: Text alignment.
    convenience init(font: UIFont,
                     color: UIColor = .black,
                     backgroundColor: UIColor = .clear,
                     lines: Int = 0,
                     alignment: NSTextAlignment = .left) {
        self.init()

        self.font            = font
        self.textColor       = color
        self.backgroundColor = backgroundColor
        self.numberOfLines   = lines
        self.textAlignment   = alignment
    }
}
