//
//  TeammateListViewModel.swift
//  DM
//
//  Created by wenyu zhao on 2020/2/1.
//  Copyright © 2020 Ryan zhao. All rights reserved.
//

import Foundation

protocol TeammateListViewModelDelegate: class {
    func loadTeammateList()
    func loadTeammateListFailed(_ errorType: FailType)
}

class TeammateListViewModel {
    // MARK: - Property
    weak var delegate: TeammateListViewModelDelegate?
    var teammateList = [Teammate]() {
        didSet {
            DispatchQueue.main.async {
                self.delegate?.loadTeammateList()
            }
        }
    }
    
    var failedType: FailType = .general {
        didSet {
            DispatchQueue.main.async {
                self.delegate?.loadTeammateListFailed(self.failedType)
            }
        }
    }
    
    // MARK: - Member function
    func getTeammatesList() {
        ServiceManager.shard.getTeammatesList { [weak self] (result) in
            guard let weakSelf = self else {
                return
            }
            
            switch result {
            case .success(let teammateList):
                weakSelf.teammateList = teammateList
                for teammate in teammateList {
                    MockChatHistoryResponse.shared.chatHistoryDB[teammate.login] = [Message]()
                }
                
            case .failure(let error):
                if error == .rateLimitReached {
                    weakSelf.failedType = .rateLimit
                } else {
                    weakSelf.failedType = .general
                }
            }
        }
    }
}
