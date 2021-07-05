//
//  PhotosCollectionViewController.swift
//  GeekBrainsTestProject
//
//  Created by Denis Mordvinov on 31.01.2021.
//

import UIKit
import Kingfisher

class PhotosCollectionViewController: UICollectionViewController, PhotosTableViewDelegateProtocol {

    let networkManager = NetworkManager.shared
    var photos: [Photo] = [] {
        didSet {
            self.collectionView.reloadData()
        }
    }

    private let reuseIdentifier = "CollectionCell"

    private var selectedUserId: Int?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let userId = self.selectedUserId {
            networkManager.getPhotosForUserId(user_id: userId) { [weak self] result in
                switch result {
                case let .failure(error):
                    print(error)
                case let .success(photos):
                    self?.photos = photos
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delegate = self
        self.collectionView.register(UINib(nibName: "FriendPhotoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView.isPagingEnabled = true
        self.view.isUserInteractionEnabled = true
        self.title = "Photos"
        let gradientView = GradientView()
        self.collectionView.backgroundView = gradientView
        self.edgesForExtendedLayout = []
        self.collectionView.delegate = self
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photos.count
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected photo cell")
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FriendPhotoCollectionViewCell

        cell.layer.borderWidth = 0.5
        cell.layer.borderColor = UIColor.black.cgColor
        let photo = photos[indexPath.row]
        cell.configure(with: photo)
        return cell
    }

    // Delegate function from FriendsController
    func didPickUserFromTableWithId(userId: Int) {
        self.selectedUserId = userId
    }
}

extension PhotosCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.frame.width / 2
        return CGSize(width: cellWidth, height: cellWidth)

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
