//
//  TeammateListViewController.swift
//  DM
//
//  Created by wenyu zhao on 2020/2/1.
//  Copyright © 2020 Ryan zhao. All rights reserved.
//

import UIKit

class TeammateListViewController: UIViewController {
    // MARK: - Property
    var viewModel: TeammateListViewModel?
    
    // MARK: - Outlet
    @IBOutlet var tableView: UITableView!
    @IBOutlet var spiner: UIActivityIndicatorView!
    
    // MARK: - Initialize
    static func instantiate(_ viewMode: TeammateListViewModel) -> TeammateListViewController {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyBoard.instantiateViewController(withIdentifier: "TeammateList") as? TeammateListViewController else {
            fatalError()
        }
        
        vc.viewModel = viewMode
        return vc
    }
    
    // MARK: - Override function
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 110, bottom: 0, right: 0)
        view.bringSubviewToFront(spiner)
        spiner.startAnimating()
        
        self.viewModel?.delegate = self
        DispatchQueue.global().async {
            self.viewModel?.getTeammatesList()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        configureNavigationBar()
    }
    
    // MARK: - Private function
    fileprivate func configureNavigationBar() {
        navigationItem.title = Constants.navigationTitle
        setLargeTitleDisplayMode(.always)
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.label,
                                                                        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 40, weight: .semibold)]
    }
}

// MARK: - TableView data source
extension TeammateListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.teammateList.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.teamlistCellIdentifier, for: indexPath) as? TeammateCell, let viewModel = viewModel else {
            return UITableViewCell()
        }
        
        cell.configureCell(teammate: viewModel.teammateList[indexPath.row])
        return cell
    }
}

// MARK: - TableView delegate
extension TeammateListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let viewModel = viewModel else {
            return
        }
        
        let teammateName = viewModel.teammateList[indexPath.row].login
        let directMessageViewModel = DirectMessageViewModel(teammateName)
        let directMessageVC = DirectMessageViewController.instantiate(directMessageViewModel)
        navigationController?.pushViewController(directMessageVC, animated: true)
    }
}

// MARK: - Delegate for viewModel
extension TeammateListViewController: TeammateListViewModelDelegate {
    func loadTeammateList() {
        tableView.reloadData()
        spiner.stopAnimating()
    }
    
    func loadTeammateListFailed(_ failedType: FailType) {
        var message = ""
        switch failedType {
        case .general:
            message = Constants.failedMessage
        case .rateLimit:
            message = Constants.rateLimitMessage
        }
        let alertVC = UIAlertController(title: Constants.failedTitle, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: Constants.confirm, style: .default, handler: { (_) in
            self.dismiss(animated: true, completion: nil)
        }))
        present(alertVC, animated: true, completion: nil)
    }
}
