//
//  DiskHelper.swift
//  TV Tracker (iOS)
//
//  Created by Tim Roesner on 6/22/21.
//

import Foundation

struct DiskHelper {
    static func save(tvShows: [TVShow]) {
        do {
            let encodedShows = try JSONEncoder().encode(tvShows)
            FileManager.default.createFile(atPath: try Self.fileURL().path, contents: encodedShows, attributes: nil)
        } catch {
            print(error)
        }
    }
    
    static func load() -> [TVShow] {
        do {
            guard let data = FileManager.default.contents(atPath: try Self.fileURL().path) else {
                throw URLError(.fileDoesNotExist)
            }
            let tvShows = try JSONDecoder().decode([TVShow].self, from: data)
            return tvShows
        } catch {
            print(error)
            return []
        }
    }
    
    private static func fileURL() throws -> URL {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw URLError(.resourceUnavailable)
        }
        return documentsURL.appendingPathComponent("tvShows.json")
    }
}
