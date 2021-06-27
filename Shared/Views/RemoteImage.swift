//
//  RemoteImage.swift
//  TV Tracker
//
//  Created by Tim Roesner on 6/4/21.
//

import SwiftUI
import Combine

struct RemoteImage: View {
    let url: URL?
    let placeholder: Image?
    
    @StateObject
    private var imageLoader = ImageLoader()
    
    var body: some View {
        if let image = imageLoader.image {
            Image(uiImage: image)
                .resizable()
        } else if let placeholder = placeholder {
            placeholder
                .resizable()
                .onAppear {
                    guard let url = url else { return }
                    imageLoader.loadImage(from: url)
                }
        }
    }
}

private var imageCache = NSCache<NSURL, UIImage>()

private class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    
    private var token: Cancellable?
    
    func loadImage(from url: URL) {
        if let image = imageCache.object(forKey: url as NSURL) {
            self.image = image
        } else {
            token = URLSession.shared.dataTaskPublisher(for: URLRequest(url: url))
                .receive(on: RunLoop.main)
                .sink { completion in
                    if case let .failure(error) = completion {
                        print("Image failed to load: \(error)")
                    }
                } receiveValue: { success in
                    guard let fetchedImage = UIImage(data: success.data) else { return }
                    self.image = fetchedImage
                    imageCache.setObject(fetchedImage, forKey: url as NSURL)
                }
        }
    }
}
