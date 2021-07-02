//
//  TVShow.swift
//  TV Tracker
//
//  Created by Tim Roesner on 5/16/21.
//

import Foundation

struct TVShow: Codable, Hashable {
    typealias Identifier = String
    
    var id: Identifier
    var name: String
    var posterURL: URL?
    var backdropURL: URL?
    var firstAirDate: Date?
    var detail: Detail?
    
    struct Detail: Codable, Hashable {
        var seasons: Int
        var inProduction: Bool
        var nextEpisode: Episode?
        var networks: [Network]
    }
    
    struct Episode: Codable, Hashable {
        typealias Identifier = String
        
        var id: Identifier
        var name: String
        var episodeNumber: Int
        var airDate: Date?
        var season: Int
        var thumbnailURL: URL?
    }
    
    struct Network: Codable, Hashable {
        typealias Identifier = String
        
        var id: Identifier
        var name: String
        var logoURL: URL?
    }
}
