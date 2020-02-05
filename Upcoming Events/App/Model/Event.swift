//
//  Event.swift
//  Upcoming Events
//
//  Created by Yariv on 2/4/20.
//  Copyright © 2020 Yariv. All rights reserved.
//

import Foundation

struct Event: Decodable, Hashable {
    let title: String
    let startDate: Date
    let endDate: Date

    enum CodingKeys: String, CodingKey {
        case title
        case startDate = "start"
        case endDate = "end"
    }
}

extension Event: Comparable {
    static func < (lhs: Event, rhs: Event) -> Bool {
        lhs.startDate < rhs.startDate
    }
}

// MARK: - Decoding

private let dateFormat = "MMMM d, yyyy h:mm a"

extension Event {
    enum DecodeError: Error {
        case invalidFile(String)
        case fileNotFound(String)
    }

    static func decodeEvents(from fileName: String) throws -> [Event] {
        let fileComponents = fileName.split(separator: ".")
        guard fileComponents.count == 2,
            let resource = fileComponents.first,
            let `extension` = fileComponents.last
            else {
                throw DecodeError.invalidFile(fileName)
        }
        guard let url = Bundle.main.url(forResource: String(resource), withExtension: String(`extension`)) else {
            throw DecodeError.fileNotFound(fileName)
        }
        let data = try Data(contentsOf: url)
        return try [Event](data: data, dateFormat: dateFormat)
    }
}

private extension Array where Element == Event {
    init(data: Data, dateFormat: String) throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(.init(dateFormat: dateFormat))
        self = try decoder.decode(type(of: self), from: data)
    }
}
