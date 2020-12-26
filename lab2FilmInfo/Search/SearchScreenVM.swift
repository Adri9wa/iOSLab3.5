//
//  SearchScreenVM.swift
//  lab2FilmInfo
//
//  Created by Adrian Chizhevskyi on 17.12.2020.
//

import RxCocoa
import RxSwift

final class SearchScreenVM: BaseViewModel {

    let loadNextData = BehaviorSubject<LoadOption>(value: LoadOption.fromStart)
    let endOfData = BehaviorRelay<Bool>(value: false)
    var lastQuery: String = ""
    var movies = [Movie]()
    private var currentPage: Int = 1
    
    override init() {
        super.init()
        loadNextData
            .skip(1)
            .subscribe(onNext: { [weak self] option in
                guard let `self` = self, self.lastQuery != "" else { return }
                self.getMovies(for: self.lastQuery, option: option)
            }).disposed(by: disposeBag)
    }
    
    private func getMovies(for query: String, option: LoadOption) {
        Observable.just(option)
            .do(onNext: { [weak self] option in self?.inProgress.onNext(true) })
            .flatMapFirst { [weak self] option -> Observable<(LoadOption, MoviesResponse)> in
                guard let `self` = self else { return Observable.empty() }
                
                switch option {
                case .fromStart:
                    self.currentPage = 1
                    return self.api.searchMovies(.searchMovies((query: query, page: self.currentPage))).map { r in (option, r) }
                case .continueLoading:
                    self.isPageLoading.accept(true)
                    self.currentPage += 1
                    return self.api.searchMovies(.searchMovies((query: query, page: self.currentPage))).map { r in (option, r) }
                case .paused:
                    return Observable.empty()
                }
            }
            .subscribe(onNext: { [weak self] option, response in
                self?.handleMoviesResponse(response, for: query, with: option)
            }, onError: { [weak self] (error) in
                self?.handleError(error)
            }).disposed(by: disposeBag)
    }
    
    private func handleMoviesResponse(_ response: MoviesResponse, for query: String, with option: LoadOption) {
        if case let .success(respMovies) = response {
            switch option {
            case .fromStart:
                movies = respMovies
            case .continueLoading:
                movies += respMovies
            case .paused:
                break
            }
            
            endOfData.accept(respMovies.isEmpty)
            dataRefreshed.onNext(respMovies.isEmpty)
            isPageLoading.accept(false)
            inProgress.onNext(false)
        } else {
            self.handleError(ApplicationError.commonError)
        }
    }

    func movieItem(at indexPath: IndexPath) -> Movie? {
        return movies[indexPath.row]
    }

}
