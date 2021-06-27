//
//  SearchView.swift
//  TV Tracker
//
//  Created by Tim Roesner on 5/31/21.
//

import SwiftUI
import Combine

struct SearchView: View {
    var dataManager: DataManager
    
    init(dataManager: DataManager) {
        self.dataManager = dataManager
    }
    
    @StateObject
    private var searchResultsLoader = SearchResultsLoader()
    
    @State
    private var searchText: String = ""
    
    var body: some View {
        VStack {
            List(searchResultsLoader.results, id: \.self) { tvShow in
                SearchResultsCell(tvShow: tvShow, dataManager: dataManager)
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .onChange(of: searchText) { newValue in
                searchResultsLoader.loadResults(for: newValue)
            }
        }
        .navigationTitle("Add TV Shows")
    }
}

struct SearchResultsCell: View {
    let tvShow: TVShow
    
    @ObservedObject
    var dataManager: DataManager
    
    var body: some View {
        HStack(alignment: .center, spacing: .mediumMargin) {
            // AsyncImage has issues when used within lists: FB9213046
            RemoteImage(url: tvShow.posterURL, placeholder: Image("cover-placeholder"))
                .aspectRatio(2/3, contentMode: .fit)
                .frame(height: 65)
                .cornerRadius(4)
            
            VStack(alignment: .leading, spacing: .tightMargin) {
                Text(tvShow.name)
                    .font(.headline)
                    .padding(.top, .tightMargin)
                
                Text(tvShow.firstAirDate?.formatted(.dateTime.year()) ?? "Unreleased")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if !dataManager.hasAdded(tvShow) {
                Button("Add") {
                    dataManager.tvShows.append(tvShow)
                }
                .font(.subheadline)
                .buttonStyle(.bordered)
            }
        }
        .padding(.vertical, .tightMargin)
        .padding(.trailing, .tightMargin)
    }
}

private class SearchResultsLoader: ObservableObject {
    @Published
    private(set) var results = [TVShow]()
    
    private let debouncer = Debouncer(timeInterval: 0.5)
    
    private var token: Cancellable?
    
    func loadResults(for searchQuery: String) {
        debouncer.handler = { [weak self] in
            guard let self = self else { return }
            async {
                do {
                    let results = try await TMDb.search(searchQuery)
                    DispatchQueue.main.async {
                        self.results = results
                    }
                } catch {
                    print(error)
                }
            }
        }
    }
}

#if DEBUG
struct SearchView_Previews: PreviewProvider {
    static fileprivate let testResults = [
        TVShow(id: "79696", name: "Manifest", posterURL: URL(tmdbPath: "/1xeiUxShzNn8TNdMqy3Hvo9o2R.jpg"), firstAirDate: Date.now, detail: nil),
        TVShow(id: "71728", name: "Young Sheldon", posterURL: URL(tmdbPath: "/aESxB2HblKlDzma39xVefa20pbW.jpg"), firstAirDate: Date.now, detail: nil),
        TVShow(id: "87083", name: "Formula 1: Drive to Survive", posterURL: URL(tmdbPath: "/hZZpqv9bKo9tUMmQY54HIJcgyqx.jpg"), firstAirDate: Date.now, detail: nil),
        TVShow(id: "97546", name: "Ted Lasso", posterURL: URL(tmdbPath: "/oX7QdfiQEbyvIvpKgJHRCgbrLdK.jpg"), firstAirDate: Date.now, detail: nil),
        TVShow(id: "1667", name: "Saturday Night Live", posterURL: URL(tmdbPath: "/bfiBW2qtdPEdcDOhYGNiP8XX8ok.jpg"), firstAirDate: Date.now, detail: nil),
    ]
    
    static var previews: some View {
        List(testResults, id: \.self) { tvShow in
            SearchResultsCell(tvShow: tvShow, dataManager: DataManager.testManager)
        }
    }
}
#endif
