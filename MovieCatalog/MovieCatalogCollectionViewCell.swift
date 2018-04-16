//
//  MovieCatalogCollectionViewCell.swift
//  MovieCatalog
//
//  Created by Vitalii Havryliuk on 4/12/18.
//  Copyright © 2018 Vitalii Havryliuk. All rights reserved.
//

import UIKit

class MovieCatalogCollectionViewCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    var posterImage: UIImage? {
        get {
            return posterImageView.image
        }
        set {
            posterImageView.image = newValue
        }
    }
    
    //MARK: - Outlets
    
    @IBOutlet weak var posterView: UIView!
    @IBOutlet weak var posterImageView: UIImageView! 
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var yearOfProductionLabel: UILabel!
    @IBOutlet weak var posterViewAspectRatio: NSLayoutConstraint!
    
    //MARK: - Methods
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.font = titleLabel.font.withSize(titleFontSize)
        yearOfProductionLabel.font = yearOfProductionLabel.font.withSize(yearFontSize)
        if let image = posterImage, posterViewAspectRatio != nil {
            posterImageView.removeConstraint(posterViewAspectRatio)
            posterViewAspectRatio = NSLayoutConstraint(
                item: posterImageView,
                attribute: .width,
                relatedBy: .equal,
                toItem: posterImageView,
                attribute: .height,
                multiplier: image.size.width / image.size.height,
                constant: 0
            )
            posterImageView.addConstraint(posterViewAspectRatio)
        }
    }
    
}

//MARK: - Extensions

extension MovieCatalogCollectionViewCell {
    
    private struct FontSizeRatio {
        static let title: CGFloat = 0.08
        static let year: CGFloat = 0.06
    }
    
    private var titleFontSize: CGFloat {
        return frame.size.height * FontSizeRatio.title
    }
    
    private var yearFontSize: CGFloat {
        return frame.size.height * FontSizeRatio.year
    }
    
}











