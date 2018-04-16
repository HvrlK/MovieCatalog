//
//  Movie.swift
//  MovieCatalog
//
//  Created by Vitalii Havryliuk on 4/12/18.
//  Copyright © 2018 Vitalii Havryliuk. All rights reserved.
//

import Foundation

struct MovieInfo: Codable, Equatable {
    
    var title: String
    var genre: String
    var yearOfProduction: String
    var description: String
    var posterData: Data
    
    static var ArchiveURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("movies").appendingPathExtension("catalog")
    
    init(title: String, genre: String, yearOfProduction: String, description: String, posterData: Data) {
        self.title = title
        self.genre = genre
        self.yearOfProduction = yearOfProduction
        self.description = description
        self.posterData = posterData
    }
    
    static func saveToFile(catalog: [MovieInfo])  {
        let propertyListEncoder = PropertyListEncoder()
        let encodedCatalog = try? propertyListEncoder.encode(catalog)
        try? encodedCatalog?.write(to: MovieInfo.ArchiveURL, options: .noFileProtection)
    }
    
    static func loadFromFile() -> [MovieInfo] {
        let propertyListDecoder = PropertyListDecoder()
        if let retrievedCatalogData = try? Data(contentsOf: MovieInfo.ArchiveURL),
            let decodedCatalog = try? propertyListDecoder.decode([MovieInfo].self, from: retrievedCatalogData) {
            return decodedCatalog
        } else {
            return []
        }
        
    }
    
}
