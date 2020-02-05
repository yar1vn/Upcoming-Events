//
//  EventsViewModel+.swift
//  Upcoming Events
//
//  Created by Yariv on 2/4/20.
//  Copyright © 2020 Yariv. All rights reserved.
//

import Foundation

// MARK: - Mock Data Loading

extension EventsViewModel {

    /// Perform a network call to fetch the data
    /// - note: `completeion` is guaranteed to be called on Main Queue
    static func load(completion: @escaping (Result<Self, Error>) -> Void) {
        DispatchQueue.main.async {
            completion(
                Result { try EventsViewModel(fileName: "mock.json") }
            )
        }
    }
}
