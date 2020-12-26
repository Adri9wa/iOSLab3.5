//
//  BaseVC.swift
//  lab2FilmInfo
//
//  Created by Adrian Chizhevskyi on 17.12.2020.
//

import UIKit

import MarkerKit
import RxSwift

class BaseVC: UIViewController {

    let activityIndicatorView = UIActivityIndicatorView(style: .gray)

    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViewAndConstraints()
        setupActivityIndicator()
        bind()
    }

    func setupViewAndConstraints() {

    }

    private func setupActivityIndicator() {
        view.addSubview(activityIndicatorView)

        activityIndicatorView.mrk.centerX(to: view)
        activityIndicatorView.mrk.centerY(to: view, relation: .equal, constant: -100)
    }

    func bind() {

    }

    final func showError(message: String) {
        showAlertController(self, title: "Error", message: message, style: .one("Ok"), handler: nil)
    }
}
