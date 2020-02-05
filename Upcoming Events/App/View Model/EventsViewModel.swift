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
    var date: String { Self.dateFormatter.string(from: model.startDate, to: model.endDate) + conflict }
    var conflict: String { isConflicted ? "❗️" : "" }

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
    /// - returns: Updated `event` with an updated `isConflicated` value
    func checkConflicts(with events: [EventViewModel]) -> Self {
        let isConflicted = !events.filter {
            guard $0.model != self.model else { return false }
            return doesOverlap(event: $0)
        }.isEmpty
        var copy = self
        copy.isConflicted = isConflicted
        return copy
    }

    /// Check if `event` conflicts with `self`.
    ///
    /// - complexity: O(1)
    mutating func checkConflicts(with event: EventViewModel) {
        isConflicted = isConflicted || doesOverlap(event: event)
    }

    init(_ event: Event) {
        self.model = event
    }
}

extension EventViewModel: CustomDebugStringConvertible {
    var debugDescription: String {
        title + (isConflicted ? " (conflicted)" : "")
    }
}

// MARK: - EventsViewModel

struct EventsViewModel {
    private let days: [Date]
    private let events: [Date: [EventViewModel]]

    /// Create a View Model from an array of Model objects.
    ///
    /// - complexity: Solution 1: O(n log n)
    /// - complexity: Solution 2: O(n^2)
    init(_ events: [Event] = []) {
        // Sort the events: O(n log n)
        var events = events.sorted().map(EventViewModel.init)

        // Assumption 1: An event can only conflict with its previous or subsequent event.
        // Solution 1: Iterate over all the events and check conflicts with index-1 and index+1.
        // Complexity: O(n)
        // Overall Comlexity: Sort + Loop = O(n log n)
        for index in (events.startIndex..<events.endIndex) {
            let previousIndex = index-1
            if previousIndex != index, previousIndex >= events.startIndex {
                events[index].checkConflicts(with: events[previousIndex])
            }
            let nextIndex = index+1
            if nextIndex != index, nextIndex < events.endIndex {
                events[index].checkConflicts(with: events[nextIndex])
            }
        }

        // Group events by day.
        // Complexity: O(n)
        let groupedEvents = Dictionary(grouping: events) {
            Calendar.current.startOfDay(for: $0.model.startDate)
        }
        self.events = groupedEvents

        /*
        // Assumption 2: An event can conflict with multiple events on the same day.
        // Solution 2: Check conlicts only between same day events.
        // Complexity: Worse case O(n^2) if ALL the events are in a single day.
        //             Average case is much lower since the nested iteration is on a small subset of n.
        //
        self.events = groupedEvents.mapValues { events in // O(n)
            events.map { event in
                event.checkConflicts(with: events) // O(n)
            }
        }
         */

        self.days = self.events.keys.sorted() // O(n log n)
    }
}

// MARK: - Table View helper functions

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

// MARK: - Decoding

extension EventsViewModel {
    init(fileName: String) throws {
        self.init(try Event.decodeEvents(from: fileName))
    }
}
