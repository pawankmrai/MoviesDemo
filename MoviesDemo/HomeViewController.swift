//
//  ViewController.swift
//  MoviesDemo
//
//  Created by Pawan on 20/11/22.
//

import UIKit

enum Section {
	case favorite
	case staffPick
}

typealias DataSource = UICollectionViewDiffableDataSource<Section, Movie>
typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Movie>

class HomeViewController: UIViewController {
	// MARK: - Outlets
	@IBOutlet weak private var collectionView: UICollectionView!
	//
	private lazy var dataSource = makeDataSource()
	private var moviesList: [Movie] = []

	override func viewDidLoad() {
		super.viewDidLoad()
		//
		configureLayout()
		//
		guard let url = URL(string: "https://apps.agentur-loop.com/challenge/staff_picks.json") else { return }
		//
		MoviesLoader.fetchMovies(url: url,
								 manager: NetworkManager()) { [weak self] response in
			//
			guard let self = self else { return }
			//
			switch response {
			case .success(let movies):
				//
				self.moviesList = movies
				//
				DispatchQueue.main.async {
					self.applySnapshot()
				}
			case .failure(let failure):
				debugPrint(failure.localizedDescription)
			}
			
		}
	}
	
	func applySnapshot() {
		var snapshot = Snapshot()
		snapshot.appendSections([.staffPick])
		snapshot.appendItems(moviesList)
		dataSource.apply(snapshot)
	}
	
	func makeDataSource() -> DataSource {
		let dataSource = DataSource(
			collectionView: collectionView
		) { (collectionView, indexPath, movie) -> UICollectionViewCell? in
			//
			guard let cell = collectionView.dequeueReusableCell(
				withReuseIdentifier: "MovieCollectionViewCell", for: indexPath) as? MovieCollectionViewCell else {
				fatalError("Couldn't dequeue MovieCollectionViewCell")
			}
			cell.lblYear.text = movie.releaseDate
			cell.lblTitle.text = movie.title
			cell.imageView.load(from: movie.posterURL)
			return cell
		}
		return dataSource
	}

}

// MARK: - Layout Handling
extension HomeViewController {
	private func configureLayout() {
		collectionView.collectionViewLayout = UICollectionViewCompositionalLayout(
			sectionProvider: { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
				let size = NSCollectionLayoutSize(
					widthDimension: NSCollectionLayoutDimension.fractionalWidth(1),
					heightDimension: NSCollectionLayoutDimension.absolute(106)
				)
				let itemCount = 1
				let item = NSCollectionLayoutItem(layoutSize: size)
				let group = NSCollectionLayoutGroup.horizontal(layoutSize: size,
															   subitem: item,
															   count: itemCount)
				let section = NSCollectionLayoutSection(group: group)
				section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
				section.interGroupSpacing = 10
				return section
			}
		)
	}
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		coordinator.animate(alongsideTransition: { context in
			self.collectionView.collectionViewLayout.invalidateLayout()
		}, completion: nil)
	}
}

extension UIImageView {
	//
	func load(from path: String) {
		if let url = URL(string: path) {
			//
			let request = URLRequest(url: url)
			//
			URLSession.shared.dataTask(with: request) { data, response, error in
				//
				if let data = data, let image = UIImage(data: data) {
					DispatchQueue.main.async {
						self.image = image
					}
				} else {
					debugPrint(error?.localizedDescription ?? "No error found")
				}
			}.resume()
		}
	}
}
