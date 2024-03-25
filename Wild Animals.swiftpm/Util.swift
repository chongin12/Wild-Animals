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

let AREA_RADIUS = 50.0 // 동물 인식 범위

let GESTURE_VELOCITY_THRESHOLD: CGFloat = 10000 // Drag의 이동 값이 10000이 넘어야 1 pat으로 침.

func random() -> CGFloat {
    return CGFloat(Float(arc4random()) / Float(0xFFFFFFFF))
}
