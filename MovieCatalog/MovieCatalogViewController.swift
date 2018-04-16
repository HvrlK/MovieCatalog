//
//  MovieCatalogViewController.swift
//  MovieCatalog
//
//  Created by Vitalii Havryliuk on 4/15/18.
//  Copyright © 2018 Vitalii Havryliuk. All rights reserved.
//

import UIKit

class MovieCatalogViewController: UIViewController, UISearchBarDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate {
    
    //MARK: - Outlets
    
    @IBOutlet weak var movieCatalogCollectionView: UICollectionView!
    @IBOutlet weak var movieSearchBar: UISearchBar!
    
    //MARK: - Properties
    
    var catalog: [MovieInfo] = []
    var isSearchActive = false
    var searchMovies: [MovieInfo] = []
    var currentCellSize: CGSize?
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MovieInfo" {
            guard let movieInfoViewController = segue.destination.contents as? MovieDetailViewController else { return }
            if let cell = sender as? MovieCatalogCollectionViewCell, let indexPath = movieCatalogCollectionView.indexPath(for: cell) {
                let movie = isSearchActive ? searchMovies[indexPath.item] : catalog[indexPath.item]
                movieInfoViewController.movieInfo = movie
            }
        }
    }
    
    @IBAction func unwindFromAddMovie(unwindSegue: UIStoryboardSegue) {
        guard let addEditMovieTableViewController = unwindSegue.source as? AddMovieTableViewController,
            let movie = addEditMovieTableViewController.movie else {return}
        catalog.insert(movie, at: 0)
        MovieInfo.saveToFile(catalog: catalog)
        movieCatalogCollectionView.reloadData()
    }
    
    @IBAction func unwindFromMovieInformation(unwindSegue: UIStoryboardSegue) {
        guard let movieDetailViewController = unwindSegue.source as? MovieDetailViewController,
            let movie = movieDetailViewController.movieInfo else {return}
        catalog.remove(at: catalog.index(of: movie)!)
        MovieInfo.saveToFile(catalog: catalog)
        movieCatalogCollectionView.reloadData()
    }
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isSearchActive {
            return searchMovies.count
        }
        return catalog.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCell", for: indexPath)
        if let movieCell = cell as? MovieCatalogCollectionViewCell {
            let movie = isSearchActive ? searchMovies[indexPath.item] : catalog[indexPath.item]
            movieCell.titleLabel.text = movie.title
            movieCell.yearOfProductionLabel.text = movie.yearOfProduction
            movieCell.posterImageView.image = UIImage(data: movie.posterData, scale: 1.0)
            movieCell.layer.cornerRadius = movieCell.frame.size.height * CellLayout.cornerRadius
        }
        return cell
    }
    
    //MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return isSearchActive ? false : true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let tempMovie = catalog.remove(at: sourceIndexPath.item)
        catalog.insert(tempMovie, at: destinationIndexPath.item)
        MovieInfo.saveToFile(catalog: self.catalog)
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return sizeForPad
        } else {
            if UIDevice.current.orientation.isLandscape {
                currentCellSize = sizeForPhoneLandscape
                return sizeForPhoneLandscape
            } else if UIDevice.current.orientation.isPortrait {
                currentCellSize = sizeForPhonePortrait
                return sizeForPhonePortrait
            } else {
                return currentCellSize!
            }
        }
    }
    
    //MARK: - UISearhBarDelegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let cancelButton = searchBar.value(forKey: "cancelButton") as? UIButton {
            cancelButton.isEnabled = true
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            searchMovies = catalog
        } else {
            searchMovies = catalog.filter { (movieInfo) -> Bool in
                let string: String = (movieInfo.title + " " + movieInfo.genre + " " + movieInfo.yearOfProduction + " " + movieInfo.description).lowercased()
                let searchWords = searchText.components(separatedBy: " ").map { $0 }
                for word in searchWords {
                    if string.range(of: word.lowercased()) == nil, word != "" {
                        return false
                    }
                }
                return true
            }
        }
        movieCatalogCollectionView.reloadData()
        searchBar.becomeFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text?.removeAll()
        searchBar.setShowsCancelButton(false, animated: true)
        isSearchActive = false
        movieCatalogCollectionView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        isSearchActive = true
        searchMovies = catalog
    }
    
    //MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        catalog = MovieInfo.loadFromFile()
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongGesture(gesture:)))
        movieCatalogCollectionView.addGestureRecognizer(longPressGesture)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        movieCatalogCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    @objc func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            guard let selectedIndexPath = movieCatalogCollectionView.indexPathForItem(at: gesture.location(in: movieCatalogCollectionView)) else { break }
            movieCatalogCollectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            movieCatalogCollectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case .ended:
            movieCatalogCollectionView.endInteractiveMovement()
        default:
            movieCatalogCollectionView.cancelInteractiveMovement()
        }
    }
    
}

//MARK: - Extensions

extension UIViewController {
    
    var contents: UIViewController {
        if let navigationController = self as? UINavigationController {
            return navigationController.visibleViewController ?? navigationController
        } else {
            return self
        }
    }
    
}

extension MovieCatalogViewController {
    
    private struct CellLayout {
        static let forPad: CGFloat = 5
        static let forPhoneInLandscape: CGFloat = 4
        static let forPhoneInPortrait: CGFloat = 2
        static let spacingForCells: CGFloat = 5
        static let cellAspectRatio: CGFloat = 0.6
        static let cornerRadius: CGFloat = 0.04
    }
    
    private var sizeForPad: CGSize {
        return CGSize(width: (movieCatalogCollectionView.frame.size.width - (movieCatalogCollectionView.layoutMargins.left + movieCatalogCollectionView.layoutMargins.right)) / CellLayout.forPad - CellLayout.spacingForCells, height: ((movieCatalogCollectionView.frame.size.width - (movieCatalogCollectionView.layoutMargins.left + movieCatalogCollectionView.layoutMargins.right)) / CellLayout.forPad - CellLayout.spacingForCells) / CellLayout.cellAspectRatio)
    }
    
    private var sizeForPhoneLandscape: CGSize {
        return CGSize(width: (movieCatalogCollectionView.frame.size.width - (movieCatalogCollectionView.layoutMargins.left + movieCatalogCollectionView.layoutMargins.right)) / CellLayout.forPhoneInLandscape - CellLayout.spacingForCells, height: ((movieCatalogCollectionView.frame.size.width - (movieCatalogCollectionView.layoutMargins.left + movieCatalogCollectionView.layoutMargins.right)) / CellLayout.forPhoneInLandscape - CellLayout.spacingForCells) / CellLayout.cellAspectRatio)
    }
    
    private var sizeForPhonePortrait: CGSize {
        return CGSize(width: (movieCatalogCollectionView.frame.size.width - (movieCatalogCollectionView.layoutMargins.left + movieCatalogCollectionView.layoutMargins.right)) / CellLayout.forPhoneInPortrait - CellLayout.spacingForCells, height: ((movieCatalogCollectionView.frame.size.width - (movieCatalogCollectionView.layoutMargins.left + movieCatalogCollectionView.layoutMargins.right)) / CellLayout.forPhoneInPortrait - CellLayout.spacingForCells) / CellLayout.cellAspectRatio)
    }
    
}
