//
//  NewsHeaderTableViewCell.swift
//  GeekBrainsTestProject
//
//  Created by Denis Mordvinov on 21.05.2021.
//

import UIKit
import Foundation

class NewsHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var headerAvatar: UIImageView!
    @IBOutlet weak var headerAuthor: UILabel!
    @IBOutlet weak var datePostLabel: UILabel!

    let realmManager = RealmManager.shared
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateFormat = "E, d MMM yyyy HH:mm"
        return formatter
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectionStyle = .none

        // Configure the view for the selected state
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.headerAvatar.setRounded()
    }

    func configure(with post: NewsFeedPost) {

        self.datePostLabel.text = self.dateFormatter.string(from: post.date)

        if post.postId < 0 {
            guard let group = try? realmManager.getObjects(selectedType: Group.self)?.filter("id == %@", -post.postId).first,
                  let avatarURL = URL(string: group.pictureUrlString) else { return }
            self.headerAuthor.text = group.name
            self.headerAvatar.kf.indicatorType = .activity
            self.headerAvatar.kf.setImage(with: avatarURL)
        } else {
            guard let friend = try? realmManager.getObjects(selectedType: Friend.self)?.filter("id == %@", post.postId).first,
                  let avatarURL = URL(string: friend.friendAvatar) else { return }
            self.headerAuthor.text = friend.name
            self.headerAvatar.kf.indicatorType = .activity
            self.headerAvatar.kf.setImage(with: avatarURL)
        }
    }
}

extension UIImageView {

    func setRounded() {
        let radius = self.frame.width / 2
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
}
