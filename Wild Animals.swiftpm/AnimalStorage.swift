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
    var id: String
    var name: String

    @Attribute(.externalStorage)
    var imageData: Data
    
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

    init(name: String, imageData: Data, location: CLLocationCoordinate2D) {
        self.id = UUID().uuidString
        self.name = name
        self.imageData = imageData
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

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}

extension Animal {
    func distance(of coordinator: CLLocationCoordinate2D) -> Double {
        return coordinator.distance(from: self.location)
    }
}

extension Animal {
    static var mockData: Animal {
        Animal(name: "고양이", imageData: UIImage(named: "cat")?.pngData() ?? Data(), location: .cat)
    }
}

extension Collection where Element == Animal {
    static var mockData: [Animal] { 
        [
            Animal(name: "고양이", imageData: UIImage(named: "cat")?.pngData() ?? Data(), location: .cat),
            Animal(name: "강아지", imageData: UIImage(named: "dog")?.pngData() ?? Data(), location: .dog),
            Animal(name: "호랑이", imageData: UIImage(named: "tiger")?.pngData() ?? Data(), location: .tiger),
            Animal(name: "판다", imageData: UIImage(named: "panda")?.pngData() ?? Data(), location: .panda),
            Animal(name: "토끼", imageData: UIImage(named: "rabbit")?.pngData() ?? Data(), location: .rabbit),
            Animal(name: "햄스터", imageData: UIImage(named: "hamster")?.pngData() ?? Data(), location: .hamster),
        ]
    }
}
