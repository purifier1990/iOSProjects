//
//  DirectMessageViewController.swift
//  DM
//
//  Created by wenyu zhao on 2020/2/2.
//  Copyright © 2020 Ryan zhao. All rights reserved.
//

import UIKit
import CoreData

class DirectMessageViewController: UIViewController {
    // MARK: - Property
    var viewModel: DirectMessageViewModel?
    var timer: Timer?
    
    // MARK: - Outlet
    @IBOutlet var tableView: UITableView!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextField: UITextField!
    
    // MARK: - Initialize
    static func instantiate(_ viewModel: DirectMessageViewModel) -> DirectMessageViewController {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyBoard.instantiateViewController(withIdentifier: "DirectMessage") as? DirectMessageViewController else {
            fatalError()
        }
        
        vc.viewModel = viewModel
        return vc
    }
    
    // MARK: - Override function
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel?.delegate = self
        configureKeyboardMisc()
        configureNavigationBar()
        retrieveCachedChatHistory()
        startPolling()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        setLargeTitleDisplayMode(.always)
        stopPolling()
        saveChatHistory()
    }
    
    // MARK: - Private function
    fileprivate func configureKeyboardMisc() {
        NotificationCenter.default.addObserver( self, selector: #selector(keyboardWillShow(note:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:)))
        view.addGestureRecognizer(tapGesture)
    }

    fileprivate func configureNavigationBar() {
        guard let name = viewModel?.teammate else {
            return
        }
        
        navigationItem.title = "@\(name)"
        setLargeTitleDisplayMode(.never)
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.label,
                                                                        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .medium)]
    }
    
    // MARK: - Polling member function
    func startPolling() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(pollingChatMessage), userInfo: nil, repeats: true)
    }
    
    func stopPolling() {
        timer?.invalidate()
    }
    
    @objc func pollingChatMessage() {
        viewModel?.pollingChatMessage()
    }
    
    // MARK: - Keyboard notification function
    @objc func keyboardWillShow(note: Notification) {
        if let keyboardSize = (note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if view.frame.origin.y == 0 {
                view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(note: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        messageTextField.resignFirstResponder()
    }
    
    // MARK: - Action
    @IBAction func sendMessage(_ sender: UIButton) {
        guard let viewModel = viewModel, let message = messageTextField.text, !message.isEmpty else {
            return
        }
        
        viewModel.sendMessage(viewModel.teammate, message)
    }
}

// MARK: - TableView data source
extension DirectMessageViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.chatHistory.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.messageCellIdentifier, for: indexPath) as? DirectMessageCell, let viewModel = viewModel else {
            return UITableViewCell()
        }
        
        cell.configure(viewModel.chatHistory[indexPath.row])
        return cell
    }
}

// MARK: - TableView delegate
extension DirectMessageViewController: UITableViewDelegate {
    
}

// MARK: - Delegate for ViewModel
extension DirectMessageViewController: DirectMessageDelegate {
    func updateHistory(_ index: [Int]) {
        guard index.count != 0 else {
            return
        }
        
        tableView.beginUpdates()
        tableView.insertRows(at: index.map({ IndexPath(row: $0, section: 0) }), with: .bottom)
        tableView.endUpdates()
        guard let viewModel = viewModel else {
            return
        }
        
        let indexPath = IndexPath(row: viewModel.chatHistory.count - 1, section: 0)
        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    func updateUIForSendMessage(_ status: SendMessageStatus) {
        switch status {
        case .success:
            messageTextField.text = nil
        default:
            break
        }
    }
}

// MARK: - TextField delegate
extension DirectMessageViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        sendMessage(sendButton)
        return true
    }
}

// MARK: - Core data for message persistence
extension DirectMessageViewController {
    func saveChatHistory() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let viewModel = viewModel else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        guard let userEntity = NSEntityDescription.entity(forEntityName: Constants.coreDataEntityName, in: managedContext) else { return }
        
        let data = ChatHistory(entity: userEntity, insertInto: managedContext)
        data.chatHistory = CacheChatHistory(history: [viewModel.teammate: viewModel.chatHistory.map({
            CacheMessage(text: $0.text, isIncoming: $0.isIncoming)
        })])
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("cound not save. \(error), \(error.userInfo)")
        }
    }
    
    func retrieveCachedChatHistory() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let viewModel = viewModel else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<ChatHistory>(entityName: Constants.coreDataEntityName)
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            var chatHitory = [Message]()
            for r in result {
                if let messages =  r.chatHistory?.history[viewModel.teammate] {
                    chatHitory = messages.map({
                        Message(text: $0.text, isIncoming: $0.isIncoming)
                    })
                }
            }
            
            viewModel.chatHistory = chatHitory

            MockChatHistoryResponse.shared.chatHistoryDB[viewModel.teammate] = chatHitory
        } catch {
            print("Failed")
        }
    }
}
