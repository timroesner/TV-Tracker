//
//  TV_TrackerApp.swift
//  Shared
//
//  Created by Tim Roesner on 5/16/21.
//

import SwiftUI

@main
struct TVTrackerApp: App {
    @Environment(\.scenePhase) private var scenePhase
    
    init() {
        DataManager.shared.tvShows = DiskHelper.load()
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ListOverview(dataManager: DataManager.shared)
            }
        }.onChange(of: scenePhase) { phase in
            if phase == .background {
                DiskHelper.save(tvShows: DataManager.shared.tvShows)
            }
        }
    }
}
