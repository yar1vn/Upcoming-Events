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
        title = "Upcoming Events"
        loadData()
    }

    private func loadData() {
        // `load` guarantees calling completion on main queue so we can refresh UI here
        EventsViewModel.load { [weak self] result in
            guard let self = self else { return }

            do {
                self.events = try result.get()
                self.tableView.reloadData()
            } catch {
                self.loadError(error)
            }
        }
    }

    private func loadError(_ error: Error) {
        let message =
        """
        Would you like to retry?
        
        (Error: \(error))
        """
        let alert = UIAlertController(title: "Cannot Load Data", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { _ in
            self.loadData()
        }))
        alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
