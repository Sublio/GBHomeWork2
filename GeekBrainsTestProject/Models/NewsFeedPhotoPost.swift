//
//  NewsFeedPhotoPost.swift
//  GeekBrainsTestProject
//
//  Created by Denis Mordvinov on 19.05.2021.
//

import Foundation
import SwiftyJSON
import UIKit

class NewsFeedPhotoPost {
    var postId: Int = 0
    var photosCount: Int = 0
    var likes: Int = 0
    var reposts: Int = 0
    var comments: Int = 0
    var photoUrls: [String] = []

    convenience init (json: SwiftyJSON.JSON) {
        self.init()
        self.postId = json["post_id"].int ?? 0
        self.photosCount = json["photos"]["count"].int ?? 0
        self.likes = json["photos"]["items"]["likes"]["count"].int ?? 0
        self.reposts = json["photos"]["items"]["reposts"]["count"].int ?? 0
        self.comments = json["photos"]["items"]["comments"]["count"].int ?? 0
    }
}
