//
//  PhotosController.swift
//  GeekBrainsTestProject
//
//  Created by Denis Mordvinov on 27.06.2021.
//

import UIKit
import AsyncDisplayKit
import Kingfisher

class ASPhotosController: ASDKViewController<ASCollectionNode>, PhotosTableViewDelegateProtocol, ASCollectionDelegate, ASCollectionDataSource {

    var collectionNode: ASCollectionNode
    let reuseIdentifier = "asyncNodeCell"
    let flowLayout: UICollectionViewLayout

    var photos = [Photo]()
    let networkManager = NetworkManager.shared
    private var selectedUserId: Int?

    override init() {
        let cellWidth = UIScreen.main.bounds.width / 2
        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewFlowLayout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        collectionViewFlowLayout.scrollDirection = .vertical
        collectionViewFlowLayout.minimumLineSpacing = 0
        collectionViewFlowLayout.minimumInteritemSpacing = 0
        self.flowLayout = collectionViewFlowLayout
        collectionNode = ASCollectionNode(collectionViewLayout: collectionViewFlowLayout)
        super.init(node: collectionNode)
        collectionNode.delegate = self
        collectionNode.dataSource = self
        collectionNode.backgroundColor = .white
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let userId = self.selectedUserId {
            networkManager.getPhotosForUserId(user_id: userId) { [weak self] result in
                switch result {
                case let .failure(error):
                    print(error)
                case let .success(photos):
                    self?.photos = photos
                    self?.collectionNode.reloadData()
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Async collection was loaded")
        collectionNode.view.isScrollEnabled = true
    }

    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return 1
    }

    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return self.photos.count
    }

    func collectionNode(_ collectionNode: ASCollectionNode, nodeForItemAt indexPath: IndexPath) -> ASCellNode {
        let image = self.photos[indexPath.row]
        if let imageUrl = image.sizes.last?.url {
            let cell = PhotoCellNode(with: URL(string: imageUrl)!)
            cell.backgroundColor = .clear
            return cell
        } else {
            return ASCellNode()
        }
    }

    // CollectionNode delegate

    func didPickUserFromTableWithId(userId: Int) {
        self.selectedUserId = userId
    }
}
