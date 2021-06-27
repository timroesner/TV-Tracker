//
//  ContentView.swift
//  Shared
//
//  Created by Tim Roesner on 5/16/21.
//

import SwiftUI

struct ListOverview: View {
    @ObservedObject
    var dataManager: DataManager
    
    var body: some View {
        Group {
            if dataManager.tvShows.isEmpty {
                emptyView
            } else {
                List {
                    ForEach(dataManager.tvShows, id: \.self) { tvShow in
                        NavigationLink(destination: DetailView(tvShow: tvShow)) {
                            ListOverviewCell(tvShow: tvShow)
                        }.swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                dataManager.remove(tvShow)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .refreshable {
                    dataManager.loadNextEpisodeAirDates()
                }
                .onAppear {
                    dataManager.loadNextEpisodeAirDates()
                }
            }
        }
        .navigationTitle("TV Shows")
        .navigationBarItems(trailing:
            NavigationLink(
                destination: SearchView(dataManager: dataManager),
                label: { Image(systemName: "magnifyingglass") }
            )
        )
    }
    
    var emptyView: some View {
        VStack(spacing: .extraWideMargin) {
            Image(systemName: "tv")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150)
            Text("No TV Shows added")
                .font(.title3)
        }
        .foregroundColor(.secondary)
    }
}

struct ListOverviewCell: View {
    let tvShow: TVShow
    
    var body: some View {
        HStack(alignment: .top, spacing: .mediumMargin) {
            // AsyncImage has issues when used within lists: FB9213046
            RemoteImage(url: tvShow.posterURL, placeholder: Image("cover-placeholder"))
                .aspectRatio(2/3, contentMode: .fit)
                .frame(height: 65)
                .cornerRadius(4)
            
            VStack(alignment: .leading, spacing: .tightMargin) {
                Text(tvShow.name)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(tvShow.detail?.inProduction ?? true
                     ? tvShow.detail?.nextEpisode?.airDate.map(formattedString(for:)) ?? "Unknown"
                     : "Cancelled"
                ).font(.title)
            }
        }
    }
    
    // MARK: - Date Formatting
    
    func formattedString(for date: Date) -> String {
        if Date.now.distance(to: date) > .week {
            return Self.furtherAwayDateFormatter.string(from: date)
        } else {
            let format = Date.FormatStyle().year().day().month()
            let formatted = Date.now.formatted(format)
            let referenceDate = try? Date(formatted, strategy: format)
            
            return Self.relativeDateFormatter.localizedString(for: date, relativeTo: referenceDate ?? Date.now)
        }
    }
    
    static let relativeDateFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        formatter.formattingContext = .beginningOfSentence
        return formatter
    }()
    
    static let furtherAwayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("MMMM dd")
        return formatter
    }()
}

#if DEBUG
struct ListOverview_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ListOverview(dataManager: DataManager.testManager)
        }
    }
}
#endif
