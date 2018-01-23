//: Playground - noun: a place where people can play

import UIKit
import Foundation
import PlaygroundSupport

enum ImageState {
    case isDownloading
    case done
}

class ImageDownloader {

    static let shared = ImageDownloader()

    private var imageQueue = [String: ImageState]()
    private let cache = NSCache<NSString, UIImage>()

    func download(
        from urlString: String,
        completion: @escaping (UIImage?, Error?) -> Void) {

        if let exists = imageQueue[urlString] {
            if exists == .isDownloading {
                print("Image is currently downloaded")
                return
            } else if exists == .done {
                print("Image was cached, returning")
                completion(cache.object(forKey: urlString as NSString), nil)
                return
            }
        }

        guard let url = URL(string: urlString) else {
            completion(nil, nil)
            return
        }

        imageQueue[urlString] = .isDownloading

        print("Start image download")

        let urlRequest = URLRequest(url: url)
        let session = URLSession.shared
        session.dataTask(
        with: urlRequest) { [weak self] data, response, error in

            self?.imageQueue[urlString] = .done
            print("Finish image download")

            if error != nil {
                completion(nil, error)
                return
            }

            guard let data = data else {
                completion(nil, error)
                return
            }

            guard let image = UIImage(data: data) else {
                completion(nil, error)
                return
            }

            print("Cache image")
            self?.cache.setObject(image, forKey: urlString as NSString)
            completion(image, nil)
            }.resume()

        PlaygroundPage.current.needsIndefiniteExecution = true
    }
}

let imageURL = "https://vignette.wikia.nocookie.net/wingsoffire/images/5/54/Panda.jpeg/revision/latest?cb=20170205005103"
for _ in 0..<4 {
    sleep(1)
    ImageDownloader.shared.download(from: imageURL) { (image, error) in
        guard let image = image else {
            return
        }

        image
    }
}
