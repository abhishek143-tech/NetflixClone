//
//  CollectionViewTableViewCell.swift
//  NetflixClone
//
//  Created by Abhishek Dilip Dhok on 19/08/23.
//

import UIKit

protocol CollectionViewTableViewCellDelegate: AnyObject {

    func CollectionViewTableViewCellDidTapCell(_ cell: CollectionViewTableViewCell, viewModel: TitlePreviewViewModel)
}

class CollectionViewTableViewCell: UITableViewCell {

    static let identifier = "CollectionViewTableViewCell"

    weak var delegate:CollectionViewTableViewCellDelegate?

    private var titles: [Title] = [Title]()

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 144, height: 200)
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(TitleCollectionViewCell.self, forCellWithReuseIdentifier: TitleCollectionViewCell.identifier)
        return collectionView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .systemPink
        contentView.addSubview(collectionView)

        collectionView.delegate = self
        collectionView.dataSource = self
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = contentView.bounds
    }

    public func configure(with titles: [Title]) {
        self.titles = titles
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
        }
    }

    private func downloadTitleAt(indexpath: IndexPath) {
        DataPersistanceManager.shared.downloadTitleWith(model: titles[indexpath.row]) { result in
            switch result {
            case .success():
                NotificationCenter.default.post(name: NSNotification.Name("Downloaded"), object: nil)

            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

extension CollectionViewTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titles.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TitleCollectionViewCell.identifier, for: indexPath) as? TitleCollectionViewCell else {
            return UICollectionViewCell()
        }

        guard let model = titles[indexPath.row].poster_path else {
            return UICollectionViewCell()
        }

        cell.configure(with: model)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        let title = titles[indexPath.row]
        guard let titleName = title.original_title ?? title.originalName else {
            return
        }

        APICaller.shared.getMovie(with: titleName + " trailer") { [weak self] result in
            switch result {
            case .success(let videoElement):
                let viewModel = TitlePreviewViewModel(title: titleName,
                                                      youtubeView: videoElement,
                                                      titleOverview: title.overview ?? "")
                guard let strongSelf = self else {
                    return
                }
                strongSelf.delegate?.CollectionViewTableViewCellDidTapCell(strongSelf, viewModel: viewModel)

            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {

        let config = UIContextMenuConfiguration(identifier: nil,
                                                previewProvider: nil) { _ in
            let downloadAction = UIAction(title: "Download",
                                          state: .off) { _ in
                self.downloadTitleAt(indexpath: indexPath)
            }
            return UIMenu(title: "", options: .displayInline, children: [downloadAction])
        }
        return config
    }
}
