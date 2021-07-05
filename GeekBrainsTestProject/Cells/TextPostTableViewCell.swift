//
//  TextPostTableViewCell.swift
//  GeekBrainsTestProject
//
//  Created by Denis Mordvinov on 21.05.2021.
//

import UIKit

class TextPostTableViewCell: UITableViewCell {

    @IBOutlet weak var postText: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectionStyle = .none

        // Configure the view for the selected state
    }

    func configure(with post: NewsFeedPost) {
        self.postText.text = post.text
        self.postText.numberOfLines = 0
        let maximumLabelSize: CGSize = CGSize(width: 280, height: 9999)
        let expectedLabelSize: CGSize = self.postText.sizeThatFits(maximumLabelSize)
        var newFrame: CGRect = self.postText.frame
        newFrame.size.height = expectedLabelSize.height
        self.postText.frame = newFrame
    }

}
