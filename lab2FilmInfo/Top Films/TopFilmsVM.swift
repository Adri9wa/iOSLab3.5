//
//  TopFilmsVM.swift
//  lab2FilmInfo
//
//  Created by Adrian Chizhevskyi on 21.12.2020.
//

import RxCocoa
import RxSwift

final class TopFilmsVM: BaseViewModel {

    var movies = [Movie]()

    var loadNextData = BehaviorSubject<LoadOption>(value: LoadOption.fromStart)
    let endOfData = BehaviorRelay<Bool>(value: false)

    private var currentPage: Int = 1

    override init() {
        super.init()

        loadNextData
            .subscribe(onNext: { [weak self] option in
                self?.getUpcomingMovies(with: option)
            }).disposed(by: disposeBag)
    }

    private func getUpcomingMovies(with option: LoadOption) {
        Observable.just(option)
            .do(onNext: { [weak self] option in self?.inProgress.onNext(true) })
            .flatMapFirst { [weak self] option -> Observable<(LoadOption, MoviesResponse)> in
                guard let `self` = self else { return Observable.empty() }

                switch option {
                case .fromStart:
                    self.currentPage = 1
                    return self.api.upcomingMovies(.upcomingMovies(page: self.currentPage)).map { r in (option, r) }
                case .continueLoading:
                    self.isPageLoading.accept(true)
                    self.currentPage += 1
                    return self.api.upcomingMovies(.upcomingMovies(page: self.currentPage)).map { r in (option, r) }
                case .paused:
                    return Observable.empty()
                }
            }
            .subscribe(onNext: { [weak self] option, response in
                self?.handleMoviesResponse(response, with: option)
            }, onError: { [weak self] (error) in
                self?.handleError(error)
            }).disposed(by: disposeBag)
    }

    private func handleMoviesResponse(_ response: MoviesResponse, with option: LoadOption) {
        if case let .success(respMovies) = response {
            switch option {
            case .fromStart:
                movies = respMovies

                if respMovies.isEmpty {
                    self.handleError(ApplicationError.noResultsError)
                }
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
