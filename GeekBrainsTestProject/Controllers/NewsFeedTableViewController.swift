//
//  NewsFeedTableViewController.swift
//  GeekBrainsTestProject
//
//  Created by Denis Mordvinov on 16.02.2021.
//

import UIKit

class NewsFeedTableViewController: UITableViewController, UITableViewDataSourcePrefetching {

    let vkService = VKService.shared

    private let textFont = UIFont.systemFont(ofSize: 14)

    private var openedTextCells: [IndexPath: Bool] = [:]

    private var posts: [NewsFeedPost] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }

    private var feedNextFromAnchor: String?

    private var nextFrom: String = ""
    private var isLoading: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 600
        let gradientView = GradientView()
        self.tableView.backgroundView = gradientView
        updateUI()
        self.refreshControl = UIRefreshControl()
        refreshControl?.tintColor = .blueZero
        refreshControl?.addTarget(self, action: #selector(refreshControlPulled), for: .valueChanged)

        tableView.prefetchDataSource = self
    }

    private func updateUI() {
        vkService.getNewsFeedTextPosts { postObjects, nextFromAnchor in
            self.posts = postObjects
            self.feedNextFromAnchor = nextFromAnchor
        }
    }

    @objc func refreshControlPulled() {
        self.refreshControl?.beginRefreshing()
        let mostFreshNewsDate = self.posts.first!.date + 2
        vkService.getNewsFeedTextPosts(startTime: mostFreshNewsDate) { [weak self] posts, _ in
            guard let self = self else { return }
            self.refreshControl?.endRefreshing()

            guard posts.count > 0 else { return }
            self.posts.insert(contentsOf: posts, at: 0)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = self.posts[indexPath.section]
        if indexPath.row == NewsFeedCellType.newsHeader.rawValue {
            let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as! NewsHeaderTableViewCell
            cell.configure(with: post)
            return cell
        } else if indexPath.row == NewsFeedCellType.textPost.rawValue {
            let cell = tableView.dequeueReusableCell(withIdentifier: "textPostCell") as! TextPostTableViewCell
            cell.configure(with: post)
            return cell

        } else if indexPath.row == NewsFeedCellType.postPicture.rawValue {
            let cell = tableView.dequeueReusableCell(withIdentifier: "pictureCell") as! NewsFeedPictureTableViewCell
            cell.configure(with: post)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "likesCell") as! LikesTableViewCell
            cell.configure(with: post)
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0, 3:
            return 50
        case 1:
            if posts[indexPath.section].text.isEmpty {
                return 0
            } else {
                return UITableView.automaticDimension
            }
        case 2:
            let aspectRatio = posts[indexPath.section].aspectRatio
            return tableView.frame.width * aspectRatio
        default:
            return UITableView.automaticDimension
        }
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0, 3:
            return 60
        case 2:
            let aspectRatio = posts[indexPath.section].aspectRatio
            return tableView.frame.width * aspectRatio
        default:
            return UITableView.automaticDimension
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.row == 1 else { return }
        let currentValue = openedTextCells[indexPath] ?? false
        openedTextCells[indexPath] = !currentValue
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    func getLabelSize(text: String, font: UIFont, availableWidth: CGFloat) -> CGSize {
        let textBlock = CGSize(width: availableWidth, height: CGFloat.greatestFiniteMagnitude)
        let rect = text.boundingRect(with: textBlock, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        let width = Double(rect.size.width)
        let height = Double(rect.size.height)
        let size = CGSize(width: ceil(width), height: ceil(height))
        return size
    }

    // MARK: - Prefetching Delegate
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        guard let feedNextFromAnchor = self.feedNextFromAnchor,
              let maxIndexPath = indexPaths.max(),
              maxIndexPath.section >= (self.posts.count - 3),
              !isLoading else { return }
        isLoading = true
        vkService.getNewsFeedTextPosts(nextFrom: feedNextFromAnchor) { [weak self] posts, nextFromAnchor in
            guard let self = self else { return }
            self.posts.append(contentsOf: posts)
            self.isLoading = false
            self.feedNextFromAnchor = nextFromAnchor
        }

        print("Prefetch batches")
    }
}
