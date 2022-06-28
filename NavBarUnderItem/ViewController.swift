//
//  ViewController.swift
//  NavBarUnderItem
//
//  Created by Mikhail Kulichkov on 24.06.22.
//

import UIKit

class ViewController: UIViewController {

    let tableView = UITableView()
    let innerLabel = UILabel()
    let innerViewHeight: CGFloat = 44
    var currentDelta: CGFloat = .zero
    var constraint: NSLayoutConstraint?

    let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Title"
        navigationController?.navigationBar.prefersLargeTitles = true

        innerLabel.backgroundColor = .green

        view.addSubview(tableView)

        tableView.contentInset.top = innerViewHeight
        DispatchQueue.main.async {
            self.tableView.scrollRectToVisible(
                .init(x: .zero, y: .zero, width: 1, height: self.innerViewHeight),
                animated: false
            )
        }

        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl = refreshControl

        refreshControl.addTarget(self, action: #selector(refreshControlChanged), for: .valueChanged)

        view.addSubview(innerLabel)

        innerLabel.text = "Inner view"
        innerLabel.translatesAutoresizingMaskIntoConstraints = false

        let topConstraint = innerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        constraint = topConstraint

        NSLayoutConstraint.activate([
            topConstraint,
            innerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            innerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            innerLabel.heightAnchor.constraint(equalToConstant: innerViewHeight)
        ])

    }

    @objc private func refreshControlChanged(_ sender: UIRefreshControl) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) { [weak refreshControl] in
            refreshControl?.endRefreshing()
        }
    }

}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        100
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell()
        cell.textLabel?.text = "item \(indexPath.item)"
        return cell
    }

}

extension ViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = UIViewController()
        vc.view.backgroundColor = .white
        vc.title = "Details"
        vc.navigationController?.navigationBar.prefersLargeTitles = false
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        processScroll(offset: scrollView.contentOffset.y)
    }

    private func processScroll(offset: CGFloat) {
        let delta = view.safeAreaInsets.top + innerViewHeight + offset

        if delta < .zero {
            constraint?.constant += currentDelta - delta
            currentDelta = delta
        } else {
            constraint?.constant = .zero
            currentDelta = .zero
        }
    }
}
