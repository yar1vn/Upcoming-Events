//
//  EventsViewController.swift
//  Upcoming Events
//
//  Created by Yariv on 2/4/20.
//  Copyright © 2020 Yariv. All rights reserved.
//

import UIKit

final class EventsViewController: UITableViewController {
    private var events = EventsViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            self.events = try EventsViewModel(fileName: "mock.json")
        } catch {
            print(error)
        }
    }
}

extension EventsViewController {
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        events.title(for: section)
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        events.sectionsCount
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events[section]?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EventCell.reuseIdentifier, for: indexPath)
        guard let eventCell = cell as? EventCell else { return cell }
        return eventCell.bind(events[indexPath])
    }
}

extension EventCell {
    @discardableResult
    func bind(_ event: EventViewModel?) -> Self {
        guard let event = event else { return self }
        titleLabel.text = event.title
        dateLabel.text = event.date
        dayLabel.text = event.day
        monthLabel.text = event.month
        dateLabel.textColor = event.isConflicted ? .systemRed : .systemGray
        return self
    }
}
