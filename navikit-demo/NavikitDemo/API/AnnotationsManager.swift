//
//  AnnotationsManager.swift
//

import MappableMobile

protocol AnnotationsManager {
    // MARK: - Public methods

    func start()
    func setAnnotationsEnabled(isEnabled: Bool)
    func setAnnotatedEventEnabled(event: AnnotatedEventsType, isEnabled: Bool)
    func setAnnotatedRoadEventEnabled(event: AnnotatedRoadEventsType, isEnabled: Bool)
}
