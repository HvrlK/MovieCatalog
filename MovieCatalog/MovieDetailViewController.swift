//
//  MovieDetailViewController.swift
//  MovieCatalog
//
//  Created by Vitalii Havryliuk on 4/15/18.
//  Copyright © 2018 Vitalii Havryliuk. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {
    
    //MARK: - Properties
    
    var movieInfo: MovieInfo?
    
    //MARK: - Outlets
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var posterImageViewAspectRatio: NSLayoutConstraint!

    //MARK: - Actions
    
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(
            title: "Are you sure?",
            message: "This item will be deleted. This action cannot be undone.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel
        ))
        alert.addAction(UIAlertAction(
            title: "Delete",
            style: .destructive,
            handler: { _ in
                self.performSegue(withIdentifier: "Delete", sender: sender)
            }
        ))
        present(alert, animated: true)
    }
    
    //MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let info = movieInfo {
            self.title = info.title
            genreLabel.text = "Genre: \(info.genre)"
            yearLabel.text = "Year: \(info.yearOfProduction)"
            descriptionLabel.text = "Description:\n\(info.description)"
            posterImageView.image = UIImage(data: info.posterData, scale: 1.0)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if posterImageViewAspectRatio != nil, let image = posterImageView.image {
            posterImageView.removeConstraint(posterImageViewAspectRatio)
            posterImageViewAspectRatio = NSLayoutConstraint(
                item: posterImageView,
                attribute: .width,
                relatedBy: .equal,
                toItem: posterImageView,
                attribute: .height,
                multiplier: image.size.width / image.size.height,
                constant: 0
            )
            posterImageView.addConstraint(posterImageViewAspectRatio)
        }
    }
    

}
