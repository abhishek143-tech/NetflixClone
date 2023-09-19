//
//  DataPersistanceManager.swift
//  NetflixClone
//
//  Created by Abhishek Dilip Dhok on 06/09/23.
//

import Foundation
import CoreData
import UIKit

class DataPersistanceManager {

    enum DatabaseError: Error {
        case failedToSaveData
        case failedToFetchData
        case failedToDeleteData
    }
    static let shared = DataPersistanceManager()

    func downloadTitleWith(model: Title, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let context = appDelegate.persistentContainer.viewContext

        let item = TitleItem(context: context)

        item.id = Int64(model.id)
        item.media_type = model.media_type
        item.originalName = model.originalName
        item.original_title = model.original_title
        item.overview = model.overview
        item.poster_path = model.poster_path
        item.release_date = model.release_date
        item.vote_average = model.vote_average
        item.vote_count = Int64(model.vote_count)

        do {
            try context.save()
            completion(.success(()))
        } catch {
            completion(.failure(DatabaseError.failedToSaveData))
        }
    }

    func fetchingTitlesFromDatabse(completion: @escaping (Result<[TitleItem], Error>) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let context = appDelegate.persistentContainer.viewContext

        let request: NSFetchRequest<TitleItem>

        request = TitleItem.fetchRequest()

        do {
            let titles = try context.fetch(request)
            completion(.success(titles))
        } catch {
            completion(.failure(DatabaseError.failedToFetchData))
        }
    }

    func deleteTitleWithModel(model: TitleItem, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let context = appDelegate.persistentContainer.viewContext

        context.delete(model)

        do {
            try context.save()
            completion(.success(()))

        } catch {
            completion(.failure(DatabaseError.failedToDeleteData))
        }
    }
}
