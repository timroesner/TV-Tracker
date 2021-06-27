//
//  DataManager.swift
//  TV Tracker
//
//  Created by Tim Roesner on 5/31/21.
//

import Foundation
import Combine

final class DataManager: ObservableObject {
    // MARK: - Public Properties
    
    static let shared = DataManager()
    
    @Published
    var tvShows = [TVShow]() {
        didSet {
            guard tvShows != oldValue else { return }
            tvShows.sort { first, second in
                // Check if either is cancelled and return early
                let isFirstCancelled = !(first.detail?.inProduction ?? true)
                let isSecondCancelled = !(second.detail?.inProduction ?? true)
                
                switch (isFirstCancelled, isSecondCancelled) {
                case (true, _): return false
                case (_, true): return true
                case (false, false): break
                }
                
                // Sort by next release date
                return first.detail?.nextEpisode?.airDate ?? .distantFuture < second.detail?.nextEpisode?.airDate ?? .distantFuture
            }
            tvShowIDs = Set(tvShows.map(\.id))
        }
    }
    
    // MARK: - Private Properties
    
    private var tvShowIDs = Set<TVShow.Identifier>()
    
    private var requestToken: Cancellable?
    
    // MARK: - Public API
    
    func remove(_ tvShow: TVShow) {
        tvShows.removeAll(where: { $0.id == tvShow.id })
    }
    
    func hasAdded(_ tvShow: TVShow) -> Bool {
        return tvShowIDs.contains(tvShow.id)
    }
    
    func loadNextEpisodeAirDates() {
        async {
            let tvShowsWithDetails = await collectNextEpisodeAirDates()
            DispatchQueue.main.async {
                self.tvShows = tvShowsWithDetails
            }
        }
    }
    
    // MARK: - Private API
    
    private func collectNextEpisodeAirDates() async -> [TVShow] {
        var tvShowDetails = [TVShow]()
        
        for tvShow in tvShows {
            do {
                let details = try await TMDb.details(for: tvShow.id)
                tvShowDetails.append(details)
            } catch {
                print(error)
                tvShowDetails.append(tvShow)
            }
        }
        
        return tvShowDetails
    }
}

#if DEBUG
extension DataManager {
    private static let dateParsingStrategy = Date.ParseStrategy(format: "\(year: .defaultDigits)-\(month: .twoDigits)-\(day: .twoDigits)", timeZone: TimeZone.current)
    
    static let testManager = DataManager(testData: [
        TVShow(
            id: "79696",
            name: "Manifest",
            posterURL: URL(tmdbPath: "/1xeiUxShzNn8TNdMqy3Hvo9o2R.jpg"),
            detail: .init(seasons: 3, inProduction: false, nextEpisode: nil, networks: [])
        ),
        TVShow(
            id: "87083",
            name: "Formula 1: Drive to Survive",
            posterURL: URL(tmdbPath: "/hZZpqv9bKo9tUMmQY54HIJcgyqx.jpg"),
            detail: .init(seasons: 4, inProduction: true, nextEpisode: nil, networks: [])
        ),
        TVShow(
            id: "97546",
            name: "Ted Lasso",
            posterURL: URL(tmdbPath: "/oX7QdfiQEbyvIvpKgJHRCgbrLdK.jpg"),
            detail: .init(
                seasons: 2,
                inProduction: true,
                nextEpisode: .init(
                    id: "2891253",
                    name: "",
                    episodeNumber: 1,
                    airDate: try? Date("2021-07-23", strategy: dateParsingStrategy),
                    season: 2,
                    thumbnailURL: nil
                ),
                networks: []
            )
        ),
        TVShow(
            id: "98161",
            name: "Home Before Dark",
            posterURL: URL(tmdbPath: "/mt4P2epJrSaqrlkMP9fTUKLP9OE.jpg"),
            detail: .init(
                seasons: 2,
                inProduction: true,
                nextEpisode: .init(
                    id: "3031348",
                    name: "Fighting His Ghost",
                    episodeNumber: 3,
                    airDate: try? Date("2021-06-25", strategy: dateParsingStrategy),
                    season: 2,
                    thumbnailURL: nil
                ),
                networks: []
            )
        ),
    ])
    
    convenience init(testData: [TVShow]) {
        self.init()
        update(tvShows: testData)
    }
    
    private func update(tvShows: [TVShow]) {
        self.tvShows = tvShows
    }
}
#endif
