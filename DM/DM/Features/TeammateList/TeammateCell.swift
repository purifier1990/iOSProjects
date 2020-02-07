//
//  TeammateCell.swift
//  DM
//
//  Created by wenyu zhao on 2020/2/1.
//  Copyright © 2020 Ryan zhao. All rights reserved.
//

import UIKit

class TeammateCell: UITableViewCell {
    // MARK: - Outlet
    @IBOutlet var avatarImage: AvatarImage!
    @IBOutlet var teammateName: UILabel!
    
    // MARK: - Member function
    func configureCell(teammate: Teammate) {
        avatarImage.image = UIImage(named: Constants.placeholderAvatarImage)
        teammateName.text = "@\(teammate.login)"
        avatarImage.imageFromServerURL(imagePath: teammate.avatarUrl)
    }
}

final class AvatarImage: UIImageView {
    // MARK: Member function
    func imageFromServerURL(imagePath: String) {
        ServiceManager.shard.getAvatarImage(imagePath: imagePath) { (result) in
            switch result {
            case .success(let data):
                guard let image = UIImage(data: data) else {
                    self.image = UIImage(named: Constants.placeholderAvatarImage)
                    return
                }
                
                DispatchQueue.main.async {
                    self.image = image
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

