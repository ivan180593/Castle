//
//  CastleViewController.swift
//  Castle
//
//  Created by Iván Estévez Nieto on 2/12/20.
//

import UIKit

final class CastleViewController: UIViewController {
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private enum Section {
        case main
    }
    private var presenter = CastlePresenter()
    private var dataSource: UICollectionViewDiffableDataSource<Section, Window>!
    private var windows = [Window]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.attachView(self)
        presenter.setup()
        setupCollectionView()
        setupNavigationBar()
    }
}

// Private methods
private extension CastleViewController {
    func setupCollectionView() {
        collectionView.setCollectionViewLayout(createLayout(), animated: false)
        
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Window> { (cell, indexPath, item) in
            var content = cell.defaultContentConfiguration()
            content.text = """
                \(item.id)
                \(item.status.rawValue)
                """
            content.textProperties.color = .blue
            cell.contentConfiguration = content
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, Window>(collectionView: collectionView) {
            (collectionView, indexPath, item) -> UICollectionViewCell? in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }

        applySnapshot(windows: presenter.getWindows())
    }
    
    func applySnapshot(windows: [Window]) {
        self.windows = windows
        var snapshot = NSDiffableDataSourceSnapshot<Section, Window>()
        snapshot.appendSections([.main])
        snapshot.appendItems(windows)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.25), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.2))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    func setupNavigationBar() {
        navigationItem.setLeftBarButton(UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(resetWindows)), animated: false)
        navigationItem.setRightBarButton(UIBarButtonItem(title: "Options", style: .plain, target: self, action: #selector(showOptionsAlert)), animated: false)
    }
    
    @objc func resetWindows() {
        applySnapshot(windows: presenter.resetWindows())
    }
    
    @objc func showOptionsAlert() {
        let alertController = UIAlertController(title: "", message: "Select an option", preferredStyle: .alert)
        let performVisitorsAction = UIAlertAction(title: "Perform visitors", style: .default) { (alertAction) in
            alertController.dismiss(animated: true) {
                self.presenter.proccessWindows(self.windows)
            }
        }
        let statusAction = UIAlertAction(title: "Status", style: .default) { (alertAction) in
            alertController.dismiss(animated: true) {
                self.presenter.windowsStatus(self.windows)
            }
        }
        let winnersAction = UIAlertAction(title: "Winners", style: .default) { (alertAction) in
            alertController.dismiss(animated: true) {
                self.presenter.windowsWinners(self.windows)
            }
        }
        let openWindowsWinnersAction = UIAlertAction(title: "Open windows winners", style: .default) { (alertAction) in
            alertController.dismiss(animated: true) {
                self.presenter.openWindowsWinner(self.windows)
            }
        }
        alertController.addAction(performVisitorsAction)
        alertController.addAction(statusAction)
        alertController.addAction(winnersAction)
        alertController.addAction(openWindowsWinnersAction)
        navigationController?.present(alertController, animated: true)
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Close", style: .cancel) { (alertAction) in
            alertController.dismiss(animated: true)
        }
        alertController.addAction(cancelAction)
        navigationController?.present(alertController, animated: true)
    }
}

// MARK: CastleViewProtocol
extension CastleViewController: CastleViewProtocol {
    func setNewWindowsStatus(windows: [Window]) {
        applySnapshot(windows: windows)
    }
    
    func showStatus(status: String) {
        showAlert(title: "Status", message: status)
    }
    
    func showWinners(winners: [Int]) {
        let message = winners.map({ String($0) }).joined(separator: ", ")
        showAlert(title: "Winners", message: message.isEmpty ? "No winners" : message)
    }
}
