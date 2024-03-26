//
//  Util.swift
//  Wild Animals
//
//  Created by 정종인 on 3/22/24.
//

import Foundation
import MapKit

extension CLLocationCoordinate2D {
    /// Returns distance from coordianate in meters.
    /// - Parameter from: coordinate which will be used as end point.
    /// - Returns: Returns distance in meters.
    func distance(from: CLLocationCoordinate2D) -> CLLocationDistance {
        let from = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let to = CLLocation(latitude: self.latitude, longitude: self.longitude)
        return from.distance(from: to)
    }
}

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

extension CLLocationCoordinate2D: Codable { // Codable을 채택하는 이유 : Animal에 @Model을 채택하기 위해서
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        self.init(latitude: latitude, longitude: longitude)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }

    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
    }
}

let AREA_RADIUS = 50.0 // 동물 인식 범위

let GESTURE_VELOCITY_THRESHOLD: CGFloat = 10000 // Drag의 이동 값이 10000이 넘어야 1 pat으로 침.

func random() -> CGFloat {
    return CGFloat(Float(arc4random()) / Float(0xFFFFFFFF))
}

import SwiftUI

extension Image {
    init(_ data: Data) {
        self.init(uiImage: UIImage(data: data) ?? UIImage())
    }
}

import CoreTransferable

struct TransferableImage: Transferable {
    let image: Image

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .image) { data in
#if canImport(UIKit)
            guard let uiImage = UIImage(data: data) else {
                return TransferableImage(image: Image(systemName: ""))
            }
            let image = Image(uiImage: uiImage)
            return TransferableImage(image: image)
#else
            return TransferableImage(image: Image(systemName: ""))
#endif
        }
    }
}


extension MKCoordinateRegion {
    func toCameraPosition() -> MapCameraPosition {
        return .region(self)
    }
}

extension CLLocationCoordinate2D {
    //    static let C5 = Self(latitude: 36.01407851917902, longitude: 129.32582384219566)
    static var cat = Self(latitude: 36.014423345211746, longitude: 129.32558167819457)
    static var dog = Self(latitude: 36.01447215110666, longitude: 129.32503969659575)
    static var tiger = Self(latitude: 36.017610689980785, longitude: 129.3220931144489)
    static var panda = Self(latitude: 36.014086474244166, longitude: 129.32634253673842)
    static var rabbit = Self(latitude: 36.01378138419845, longitude: 129.32627811663477)
    static var hamster = Self(latitude: 36.01407851917902, longitude: 129.32582384219566)
}

extension UIImage {
    var fixedOrientation: UIImage {
        guard imageOrientation != .up else { return self }

        var transform: CGAffineTransform = .identity
        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform
                .translatedBy(x: size.width, y: size.height).rotated(by: .pi)
        case .left, .leftMirrored:
            transform = transform
                .translatedBy(x: size.width, y: 0).rotated(by: .pi)
        case .right, .rightMirrored:
            transform = transform
                .translatedBy(x: 0, y: size.height).rotated(by: -.pi/2)
        case .upMirrored:
            transform = transform
                .translatedBy(x: size.width, y: 0).scaledBy(x: -1, y: 1)
        default:
            break
        }

        guard
            let cgImage = cgImage,
            let colorSpace = cgImage.colorSpace,
            let context = CGContext(
                data: nil, width: Int(size.width), height: Int(size.height),
                bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0,
                space: colorSpace, bitmapInfo: cgImage.bitmapInfo.rawValue
            )
        else { return self }
        context.concatenate(transform)

        var rect: CGRect
        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            rect = CGRect(x: 0, y: 0, width: size.height, height: size.width)
        default:
            rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        }

        context.draw(cgImage, in: rect)
        return context.makeImage().map { UIImage(cgImage: $0) } ?? self
    }
}


extension UIImage: Transferable {
    static public var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .image) { data in
            guard let uiImage = UIImage(data: data) else {
                return UIImage(systemName: "exclamationmark.triangle.fill")!
            }
            return uiImage
        }
    }


}
