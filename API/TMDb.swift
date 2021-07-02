//
//  TMDb.swift
//  TV Tracker
//
//  Created by Tim Roesner on 5/16/21.
//

import Foundation

struct TMDb {
    static func search(_ query: String) async throws -> [TVShow] {
        let queryItems: [URLQueryItem] = [
            .init(name: "api_key", value: Credential.apiKey),
            .init(name: "query", value: query)
        ]
        
        let searchRoot = try await HTTP.request(SearchRoot.self, url: URL(string: "https://api.themoviedb.org/3/search/tv"), params: queryItems)
        return searchRoot.data.map(TVShow.init)
    }
    
    static func details(for tvID: TVShow.Identifier) async throws -> TVShow {
        let queryItems = [ URLQueryItem(name: "api_key", value: Credential.apiKey) ]
        
        let tvShowWithDetails = try await HTTP.request(TVShowDetails.self, url: URL(string: "https://api.themoviedb.org/3/tv/\(tvID)"), params: queryItems)
        return TVShow(tvShowWithDetails)
    }
}

// MARK: - Decoding Helpers

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
}()

// MARK: - Search Structs

private struct SearchRoot: Codable {
    let data: [TVShowData]
    
    enum CodingKeys: String, CodingKey {
        case data = "results"
    }
}

private struct TVShowData: Codable {
    let id: Int
    let name: String
    let posterPath: String?
    let backdropPath: String?
    let firstAirDate: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case firstAirDate = "first_air_date"
    }
}

private extension TVShow {
    init(_ data: TVShowData) {
        self.init(
            id: String(data.id), name: data.name,
            posterURL: URL(tmdbPath: data.posterPath),
            backdropURL: URL(tmdbPath: data.backdropPath),
            firstAirDate: data.firstAirDate.flatMap({ dateFormatter.date(from: $0) }),
            detail: nil
        )
    }
}

// MARK: - Details Structs

private struct TVShowDetails: Codable {
    let id: Int
    let inProduction: Bool
    let name: String
    let nextEpisode: Episode?
    let networks: [Network]
    let numberOfSeasons: Int
    let posterPath: String?
    let backdropPath: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case inProduction = "in_production"
        case name
        case nextEpisode = "next_episode_to_air"
        case networks
        case numberOfSeasons = "number_of_seasons"
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
    }
}

private struct Episode: Codable {
    let airDate: String
    let episodeNumber, id: Int
    let name, overview, productionCode: String
    let seasonNumber: Int
    let stillPath: String?
    
    enum CodingKeys: String, CodingKey {
        case airDate = "air_date"
        case episodeNumber = "episode_number"
        case id, name, overview
        case productionCode = "production_code"
        case seasonNumber = "season_number"
        case stillPath = "still_path"
    }
}

private struct Network: Codable {
    let name: String
    let id: Int
    let logoPath: String?
    let originCountry: String
    
    enum CodingKeys: String, CodingKey {
        case name, id
        case logoPath = "logo_path"
        case originCountry = "origin_country"
    }
}

private extension TVShow {
    init(_ details: TVShowDetails) {
        let detail = TVShow.Detail(seasons: details.numberOfSeasons, inProduction: details.inProduction, nextEpisode: details.nextEpisode.map(TVShow.Episode.init), networks: details.networks.map(TVShow.Network.init))
        self.init(id: String(details.id), name: details.name, posterURL: URL(tmdbPath: details.posterPath), backdropURL: URL(tmdbPath: details.backdropPath), detail: detail)
    }
}

private extension TVShow.Episode {
    init(_ nextEpisode: Episode) {
        self.init(id: String(nextEpisode.id), name: nextEpisode.name, episodeNumber: nextEpisode.episodeNumber, airDate: dateFormatter.date(from: nextEpisode.airDate),
                  season: nextEpisode.seasonNumber, thumbnailURL: URL(tmdbPath: nextEpisode.stillPath))
    }
}

private extension TVShow.Network {
    init(_ network: Network) {
        self.init(id: String(network.id), name: network.name, logoURL: URL(tmdbPath: network.logoPath))
    }
}

// MARK: - URL Helper

extension URL {
    init?(tmdbPath: String?) {
        guard let tmdbPath = tmdbPath, let fullURL = URL(string: "https://image.tmdb.org/t/p/w500\(tmdbPath)") else { return nil }
        self = fullURL
    }
}
