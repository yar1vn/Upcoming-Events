//
//  EventsViewModel.swift
//  Upcoming Events
//
//  Created by Yariv on 2/4/20.
//  Copyright © 2020 Yariv. All rights reserved.
//

import Foundation

// MARK: - EventViewModel

struct EventViewModel {
    private static let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter
    }()

    private static let dateFormatter: DateIntervalFormatter = {
        let formatter = DateIntervalFormatter()
        formatter.dateStyle = .none
        return formatter
    }()

    var title: String { model.title }
    var month: String { Self.monthFormatter.string(from: model.startDate).uppercased() }
    var day: String { "\(Calendar.current.component(.day, from: model.startDate))" }
    var date: String { Self.dateFormatter.string(from: model.startDate, to: model.endDate) }
    private(set) var isConflicted: Bool = false
    fileprivate let model: Event

    /// 2 events don't overlap if:
    ///  one begins before the other ends OR
    ///  the other ends before one begins
    ///
    /// - complexity: O(1)
    private func doesOverlap(event: EventViewModel) -> Bool {
        !(self.model.endDate <= event.model.startDate ||
            self.model.startDate >= event.model.endDate)
    }

    /// Loop over `events` and check if it conflicts with `self`.
    ///
    /// - note: this method will ignore `self` if it's contained in `events`
    /// - complexity: O(n)
    func checkConflicts(with events: [EventViewModel]) -> Self {
        let isConflicted = !events.filter {
            guard $0.model != self.model else { return false }
            return doesOverlap(event: $0)
        }.isEmpty
        var copy = self
        copy.isConflicted = isConflicted
        return copy
    }

    init(_ event: Event) {
        self.model = event
    }
}

// MARK: - EventsViewModel

struct EventsViewModel {
    private let days: [Date]
    private let events: [Date: [EventViewModel]]

    /// Create a View Model from an array of Model objects.
    ///
    ///
    /// - complexity: O(n^2)
    init(_ events: [Event] = []) {
        // Sort and group events by day.
        // sorting: O(n log n)
        // grouping: O(n)
        let groupedEvents = Dictionary(grouping: events.sorted().map(EventViewModel.init)) {
            Calendar.current.startOfDay(for: $0.model.startDate)
        }
        // O(n^2)
        // However each event will only check conflicts with events in the same day.
        self.events = groupedEvents.mapValues { events in // O(n)
            events.map { event in
                event.checkConflicts(with: events) // O(n)
            }
        }
        self.days = self.events.keys.sorted() // O(n log n)
    }
}

// MARK: - Table View Helper Functions

extension EventsViewModel {
    var sectionsCount: Int { days.count }

    func title(for section: Int) -> String? {
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

// MARK: - Custom intialiazer

extension EventsViewModel {
    init(fileName: String) throws {
        self.init(try Event.parseEvents(from: fileName))
    }
}
