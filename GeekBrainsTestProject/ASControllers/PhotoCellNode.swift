//
//  PhotoCellNode.swift
//  GeekBrainsTestProject
//
//  Created by Denis Mordvinov on 27.06.2021.
//

import Foundation
import AsyncDisplayKit
import UIKit

class PhotoCellNode: ASCellNode, ASNetworkImageNodeDelegate {
    let networkImageNode = ASNetworkImageNode()
    var activityIndicator: UIActivityIndicatorView?

    required init(with imageUrl: URL) {
        super.init()
        networkImageNode.contentMode = .scaleAspectFill
        self.addSubnode(networkImageNode)
        networkImageNode.url = imageUrl
        self.automaticallyManagesSubnodes = true
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let imageNodeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let imageNodeLayout = ASInsetLayoutSpec(insets: imageNodeInsets, child: networkImageNode)
        return imageNodeLayout
    }

    func setupActivityIndicator(bounds: CGSize) -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        var newRect = activityIndicator.frame
        newRect.origin = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
        activityIndicator.frame = newRect
        return activityIndicator
    }

    // Image Node delegate

    func imageNode(_ imageNode: ASNetworkImageNode, didLoad image: UIImage) {
        if let activityIndicator = self.activityIndicator {
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
            self.activityIndicator = nil
        }
        self.setNeedsLayout()
    }

    func imageNodeDidStartFetchingData(_ imageNode: ASNetworkImageNode) {
        self.activityIndicator = setupActivityIndicator(bounds: imageNode.style.preferredSize)
        if let indicator = self.activityIndicator {
            imageNode.view.addSubview(indicator)
            indicator.startAnimating()
        }
    }

    func imageNodeDidFailToLoadImage(fromCache imageNode: ASNetworkImageNode) {
        if let activityIndicator = self.activityIndicator {
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
            self.activityIndicator = nil
        }
        self.setNeedsLayout()
    }

}
