//
//  EventsViewModel.swift
//  Upcoming Events
//
//  Created by Yariv on 2/4/20.
//  Copyright © 2020 Yariv. All rights reserved.
//

import Foundation

struct EventViewModel {
    fileprivate let event: Event

    private static let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter
    }()

    private static let dateFormatter: DateIntervalFormatter = {
        let formatter = DateIntervalFormatter()
        return formatter
    }()

    var title: String { event.title }
    var month: String { Self.monthFormatter.string(from: event.startDate).uppercased() }
    var day: String { "\(Calendar.current.component(.day, from: event.startDate))" }
    var date: String { Self.dateFormatter.string(from: event.startDate, to: event.endDate) }

    func doesOverlap(event: EventViewModel) -> Bool {
        // 2 events don't overlap if:
        //  one begins before the other ends OR
        //  the other ends before one begins
        //  S1|----|E1   S2|----|E2
        !(self.event.endDate <= event.event.startDate ||
            self.event.startDate >= event.event.endDate)
    }
}

struct EventsViewModel {
    private let days: [Date]
    private let events: [Date: [EventViewModel]]

    init(_ events: [Event] = []) {
        // O(n)
        self.events = Dictionary(grouping: events.map(EventViewModel.init)) { event in
            Calendar.current.startOfDay(for: event.event.startDate)
        }
        // O(n log n)
        self.days = self.events.keys.sorted()
    }
}

extension EventsViewModel {
    var sectionsCount: Int { days.count }

    func title(section: Int) -> String? {
        let day = days[section]
        guard let event = events[day]?.first else { return nil }
        return "\(event.month) \(event.day)"
    }

    subscript(section: Int) -> [EventViewModel]? {
        let day = days[section]
        return events[day]
    }

    subscript(indexPath: IndexPath) -> EventViewModel? {
        let day = days[indexPath.section]
        return events[day]?[indexPath.row]
    }
}

extension EventsViewModel {
    init(fileName: String) throws {
        self.init(try Event.parseEvents(from: fileName))
    }
}
