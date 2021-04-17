//
//  User.swift
//  GeekBrainsTestProject
//
//  Created by Denis Mordvinov on 01.02.2021.
//

import SwiftyJSON
import UIKit
import RealmSwift

@objcMembers
class Friend: RealmSwift.Object {
    dynamic var name: String = ""
    dynamic var id: Int = 0
    dynamic var friendAvatar: String = ""

    // let friendPhotos = LinkingObjects(fromType: Photo.self, property:"photoStringUrlMedium")

    convenience init (json: SwiftyJSON.JSON) {
        self.init()
        let firstName = json["first_name"].string ?? ""
        let lastName = json["last_name"].string ?? ""
        self.name = firstName + " " + lastName
        self.friendAvatar = json["photo_50"].string ?? ""
        self.id = json["id"].int ?? 0
    }

    override static func primaryKey() -> String? {
        "id"
    }
}
