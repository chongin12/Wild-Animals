//
//  AnimalStorage.swift
//  Wild Animals
//
//  Created by 정종인 on 3/22/24.
//

import Foundation
import MapKit
import SwiftData

@Model final class Animal {
    var name: String
    var imageString: String
    var location: CLLocationCoordinate2D
    var food: Int = 0 {
        didSet {
            if food > 1000 {
                food = 999
            }
        }
    }
    var pat: Int = 0 {
        didSet {
            if pat > 1000 {
                pat = 999
            }
        }
    }

    init(name: String, imageString: String, location: CLLocationCoordinate2D) {
        self.name = name
        self.imageString = imageString
        self.location = location
    }

    enum Growth {
        case small
        case medium
        case big

        var scale: CGFloat {
            switch self {
            case .small:
                0.5
            case .medium:
                0.7
            case .big:
                1.0
            }
        }

        var description: String {
            switch self {
            case .small:
                "갓 태어난"
            case .medium:
                "부모로부터 독립할 때가 된"
            case .big:
                "다 큰"
            }
        }
    }

    var growth: Growth {
        if food > 20 && pat > 20 {
            return .big
        } else if food > 10 || pat > 10 {
            return .medium
        } else {
            return .small
        }
    }

    var canTouch: Bool {
        distance <= AREA_RADIUS
    }
    var distance: Double {
        LocationDataManager.shared.currentCoordinator.distance(from: self.location)
    }

    @MainActor
    public func foodIncrement() {
        self.food += 1
    }

    @MainActor
    public func patIncrement() {
        self.pat += 1
    }

    @MainActor
    public func reset() {
        self.food = 0
        self.pat = 0
    }
}

extension Animal: Identifiable, Hashable {
    @Transient
    var id: String {
        self.name
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.name)
    }
}

extension Animal {
    func distance(of coordinator: CLLocationCoordinate2D) -> Double {
        return coordinator.distance(from: self.location)
    }
}

extension Animal {
    static var mockData: Animal {
        Animal(name: "고양이", imageString: "cat", location: .cat)
    }
}

extension Collection where Element == Animal {
    static var mockData: [Animal] { 
        [
            Animal(name: "고양이", imageString: "cat", location: .cat),
            Animal(name: "강아지", imageString: "dog", location: .dog),
            Animal(name: "호랑이", imageString: "tiger", location: .tiger),
            Animal(name: "판다", imageString: "panda", location: .panda),
            Animal(name: "토끼", imageString: "rabbit", location: .rabbit),
            Animal(name: "햄스터", imageString: "hamster", location: .hamster),
        ]
    }
}
