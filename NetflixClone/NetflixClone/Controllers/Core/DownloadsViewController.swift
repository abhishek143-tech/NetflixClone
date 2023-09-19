//
//  DownloadsViewController.swift
//  NetflixClone
//
//  Created by Abhishek Dilip Dhok on 19/08/23.
//

import UIKit

class DownloadsViewController: UIViewController {

    private var titles: [TitleItem] = [TitleItem]()

    private let downloadsTable: UITableView = {
        let table = UITableView()
        table.register(TitleTableViewCell.self, forCellReuseIdentifier: TitleTableViewCell.identifier)
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Downloads"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always

        view.addSubview(downloadsTable)
        downloadsTable.delegate = self
        downloadsTable.dataSource = self

        fetchLocalStorageForDownloads()
        NotificationCenter.default.addObserver(forName: NSNotification.Name("Downloaded"), object: nil, queue: nil) { _ in
            self.fetchLocalStorageForDownloads()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        downloadsTable.frame = view.bounds
    }

    private func fetchLocalStorageForDownloads() {
        DataPersistanceManager.shared.fetchingTitlesFromDatabse { [weak self] result in
            switch result {
            case .success(let titles):
                self?.titles = titles
                self?.downloadsTable.reloadData()

            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

extension DownloadsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TitleTableViewCell.identifier, for: indexPath) as? TitleTableViewCell else {
            return UITableViewCell()
        }
        let title = titles[indexPath.row]
        cell.configure(with: TitleViewModel(titleName: title.original_title ?? title.originalName ?? "", posterURL: title.poster_path ?? ""))
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            DataPersistanceManager.shared.deleteTitleWithModel(model: titles[indexPath.row]) { [weak self] result in
                switch result {
                case .success():
                    print("Deleted")

                case .failure(let error):
                    print(error.localizedDescription)
                }
                self?.titles.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            default:
                break
        }
    }

}
