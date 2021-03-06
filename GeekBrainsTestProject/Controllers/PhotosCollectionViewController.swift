//
//  PhotosCollectionViewController.swift
//  GeekBrainsTestProject
//
//  Created by Denis Mordvinov on 31.01.2021.
//

import UIKit
import RealmSwift

class PhotosCollectionViewController: UICollectionViewController, PhotosTableViewDelegateProtocol {

    private var notificationToken: NotificationToken?

    let realmManager = RealmManager.shared
    let networkManager = NetworkManager.shared
    var cacheManager: CacheManager?
    var photos: [Photo] = [] // This array is for populating PhotosCollectionViewController

    private let reuseIdentifier = "CollectionCell"

    private var selectedUserId: Int?

    let activityView = UIActivityIndicatorView(style: .large)

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let cacheManager = CacheManager(container: self.collectionView)
        self.cacheManager = cacheManager
        guard let selectedUser = selectedUserId else { return }

        if iSMeededToUpdatePhotos() {
            retrievePhotosForUserId(userId: selectedUser)
        } else {
            guard let user = self.realmManager.getFriendInfoById(id: selectedUser) else { return }
            self.photos = Array(user.friendPhotos)
        }
    }

    func iSMeededToUpdatePhotos() -> Bool {
        guard let selectedUserId = self.selectedUserId else { fatalError("User id must not be nil or empty") }
        let selectedUser = realmManager.getFriendInfoById(id: selectedUserId)
        return  (selectedUser?.friendPhotos.isEmpty)! ? true : false
    }

    func retrievePhotosForUserId(userId: Int) {
        let fadeView: UIView = UIView()
        fadeView.frame = self.collectionView.frame
        fadeView.backgroundColor = .white
        fadeView.alpha = 0.4
        self.view.addSubview(fadeView)
        self.view.addSubview(activityView)
        activityView.hidesWhenStopped = true
        activityView.center = self.view.center
        activityView.startAnimating()
        networkManager.getPhotosForUserId(user_id: userId, completion: {[weak self] result in
            switch result {
            case let .failure(error):
                print(error)
            case let .success(photos):
                photos.forEach {
                    if let pictureData = self?.networkManager.getDataFrom(photoURl: $0.photoStringUrlMedium) {
                        $0.picture = pictureData
                    }
                    guard let selectedUserId = self?.selectedUserId else { fatalError("User id must not be nil or empty") }
                    self?.realmManager.updatePhotosStorageForFriend(friendId: selectedUserId, photo: $0)
                }
                let friend = self?.realmManager.getFriendInfoById(id: self?.selectedUserId ?? 0)
                self?.photos = Array(friend!.friendPhotos)
                self?.collectionView.alpha = 1
                fadeView.removeFromSuperview()
                self?.activityView.stopAnimating()
            }
        })
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

        // observe photos for particular users
        guard let currentUserObject = self.realmManager.getObjects(selectedType: Friend.self)?.filter("id == %@", selectedUserId ?? 0).first else { return }
        let photosOfCurrentFriend = currentUserObject.friendPhotos
        self.notificationToken = photosOfCurrentFriend.observe({ (changes: RealmCollectionChange) in
            switch changes {
            case .initial:
                self.collectionView.reloadData()
            case  .update:
                let friend = self.realmManager.getFriendInfoById(id: self.selectedUserId ?? 0)
                self.photos = Array(friend!.friendPhotos)
                self.collectionView.reloadData()
            case .error(let error):
                print(error)
            }
        })
    }

    deinit {
        notificationToken?.invalidate()
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photos.count
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FriendPhotoCollectionViewCell

        cell.layer.borderWidth = 0.5
        cell.layer.borderColor = UIColor.black.cgColor
        let photo = photos[indexPath.row]
        let photoUrl = photo.photoStringUrlMedium
        cell.photo.image = cacheManager?.photo(at: indexPath, byUrl: photoUrl)
        cell.spinner.stopAnimating()
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
