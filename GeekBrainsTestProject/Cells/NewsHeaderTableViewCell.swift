//
//  NewsHeaderTableViewCell.swift
//  GeekBrainsTestProject
//
//  Created by Denis Mordvinov on 21.05.2021.
//

import UIKit

class NewsHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var headerAvatar: UIImageView!
    @IBOutlet weak var headerAuthor: UILabel!
    @IBOutlet weak var datePostLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(with post: NewsFeedPost) {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .medium
        self.datePostLabel.text = dateFormatter.string(from: post.date)
        self.headerAvatar.image = UIImage(named: "face1")
        self.headerAuthor.text = "Test"
    }

}
