//
//  DetailView.swift
//  TV Tracker
//
//  Created by Tim Roesner on 6/21/21.
//

import SwiftUI

struct DetailView: View {
    let tvShow: TVShow
    
    var episode: TVShow.Episode? {
        tvShow.detail?.nextEpisode
    }
    
    var episodeName: String {
        if let episodeName = episode?.name, !episodeName.isEmpty {
            return episodeName
        } else {
            return "TBD"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: .mediumMargin) {
            heroImage
            
            Text((tvShow.detail?.inProduction ?? true) ? episodeName : "Cancelled")
                .font(.title2)
            
            HStack(spacing: .extraWideMargin) {
                if let seasonNumber = episode?.season, let episodeNumber = episode?.episodeNumber {
                    Text("Season \(seasonNumber)")
                    Text("Episode \(episodeNumber)")
                }
            }.foregroundColor(.secondary)
            
            releaseDate
            networksSection
            Spacer()
        }
        .padding()
        .navigationTitle(tvShow.name)
    }
    
    var heroImage: some View {
        AsyncImage(
            url: tvShow.detail?.nextEpisode?.thumbnailURL ?? tvShow.backdropURL,
            content: { imageView in
            imageView
                .resizable()
                .aspectRatio(16 / 9, contentMode: .fit)
                .cornerRadius(6)
            },
            placeholder: {
                Image(systemName: "photo.tv")
                    .resizable()
                    .foregroundColor(Color(uiColor: .tertiaryLabel))
                    .aspectRatio(contentMode: .fit)
                    .padding(50)
            }
        )
    }
    
    @ViewBuilder
    var releaseDate: some View {
        if let releaseDate = episode?.airDate {
            VStack(alignment: .leading, spacing: .tightMargin) {
                Text("Release Date")
                    .font(.subheadline)
                Text(releaseDate.formatted(.dateTime.year().day().month()))
                    .font(.title3)
            }
            .padding(.top, .extraWideMargin)
        }
    }
    
    @ViewBuilder
    var networksSection: some View {
        if let networks = tvShow.detail?.networks, !networks.isEmpty {
            Text(networks.count > 1 ? "Networks" : "Network")
                .font(.subheadline)
                .padding(.top, .extraWideMargin + .standardMargin)
            HStack {
                ForEach(networks, id: \.self) { network in
                    VStack {
                        if let logoURL = network.logoURL {
                            AsyncImage(url: logoURL, content: { imageView in
                                imageView
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            }, placeholder: {
                                Color.clear
                            })
                                .frame(width: 44, height: 44)
                                .padding(.standardMargin)
                                .background(Color(uiColor: .secondarySystemBackground))
                                .cornerRadius(12)
                        }
                        Text(network.name)
                            .font(.caption)
                    }
                }
            }
        }
    }
}

#if DEBUG
struct DetailView_Previews: PreviewProvider {
    static let testShow: TVShow = {
        let nextEpisode = TVShow.Episode(id: "3031348", name: "Fighting His Ghost", episodeNumber: 3, airDate: Date(timeIntervalSinceNow: 4 * .day),
                                         season: 2, thumbnailURL: nil)
        let network = TVShow.Network(id: "2552", name: "Apple TV+", logoURL: URL(tmdbPath: "/4KAy34EHvRM25Ih8wb82AuGU7zJ.png"))
        let detail = TVShow.Detail(seasons: 2, inProduction: true, nextEpisode: nextEpisode, networks: [network])
        return TVShow(id: "98161", name: "Home Before Dark", posterURL: URL(tmdbPath: "/mt4P2epJrSaqrlkMP9fTUKLP9OE.jpg"),
                      firstAirDate: Date(timeIntervalSinceNow: -365 * .day), detail: detail)
    }()
    
    static var previews: some View {
        NavigationView {
            DetailView(tvShow: testShow)
        }
    }
}
#endif
