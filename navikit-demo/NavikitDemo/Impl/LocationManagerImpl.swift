//
//  LocationManagerImpl.swift
//

import Combine
import MappableMobile

final class LocationManagerImpl: BasicGuidanceListener, LocationManager {
    // MARK: - Public properties

    var location = CurrentValueSubject<MMKLocation?, Never>(nil)

    // MARK: - Constructor

    init(guidance: MMKGuidance) {
        self.guidance = guidance

        super.init()
    }

    // MARK: - Public properties

    override func onLocationChanged() {
        if let lastUpdateTime,
           lastUpdateTime.distance(to: Date()) < Const.locationUpdateTimeout {
            return
        }

        lastUpdateTime = Date()

        location.send(guidance.location)
    }

    func addGuidanceListener() {
        guidance.addListener(with: self)
    }

    func removeGuidanceListener() {
        guidance.removeListener(with: self)
    }

    // MARK: - Private properties

    private let guidance: MMKGuidance
    private var lastUpdateTime: Date?

    // MARK: - Private nesting

    private enum Const {
        static let locationUpdateTimeout: TimeInterval = 1.0
    }
}
