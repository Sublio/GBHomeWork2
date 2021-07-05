//
//  NewsFeedPictureTableViewCell.swift
//  GeekBrainsTestProject
//
//  Created by Denis Mordvinov on 23.05.2021.
//

import UIKit
import Kingfisher

class NewsFeedPictureTableViewCell: UITableViewCell {

    @IBOutlet weak var picture: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectionStyle = .none

        // Configure the view for the selected state
    }

    func configure(with post: NewsFeedPost) {
        guard let photoURL = URL(string: post.postPhotoURL) else { return }
        self.picture.kf.indicatorType = .activity
        self.picture.kf.setImage(with: photoURL)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        picture.image = nil
    }
}
