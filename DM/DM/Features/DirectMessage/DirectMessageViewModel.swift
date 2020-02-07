//
//  DirectMessageViewModel.swift
//  DM
//
//  Created by wenyu zhao on 2020/2/2.
//  Copyright © 2020 Ryan zhao. All rights reserved.
//

protocol DirectMessageDelegate: class {
    func updateHistory(_ index: [Int])
    func updateUIForSendMessage(_ status: SendMessageStatus)
}

class DirectMessageViewModel {
    // MARK: Property
    var teammate: String
    var chatHistory = [Message]() {
        didSet {
            if oldValue != chatHistory {
                oldHistory = oldValue
                delegate?.updateHistory(getDiffForHistory())
            }
        }
    }
    var oldHistory = [Message]()
    
    var sendMessageStatus: SendMessageStatus = .idle {
        didSet {
            delegate?.updateUIForSendMessage(sendMessageStatus)
        }
    }
    
    weak var delegate: DirectMessageDelegate?
    
    // MARK: - Initialize
    init(_ teammate: String) {
        self.teammate = teammate
    }
    
    // MARK: - Private function
    fileprivate func getDiffForHistory() -> [Int] {
        var diff = [Int]()
        guard !oldHistory.isEmpty else {
            for i in 0 ..< chatHistory.count {
                diff.append(i)
            }
            return diff
        }
        
        for i in (0 ..< chatHistory.count).reversed() {
            if let last = oldHistory.last {
                if (last == chatHistory[i]) {
                    break;
                }
                if (last != chatHistory[i]) {
                    diff.append(i)
                }
            }
        }
        
        return diff
    }
    
    // MARK: - Member function
    func sendMessage(_ name: String,
                     _ message: String) {
        ServiceManager.shard.mockPostMessage(name,
                                             message) { [weak self] (result) in
                                                switch result {
                                                case . success(()):
                                                    self?.sendMessageStatus = .success
                                                    self?.chatHistory.append(Message(text: message, isIncoming: false))
                                                case .failure(_):
                                                    self?.sendMessageStatus = .idle
                                                }
        }
    }
    
    func pollingChatMessage() {
        ServiceManager.shard.mockGetChatMessages(teammate) { [weak self] (result) in
            switch result {
            case .success(let chatMessages):
                self?.chatHistory = chatMessages
            case .failure(let error):
                print(error)
            }
        }
    }
}
