//
//  CameraManagerImpl.swift
//

import Combine
import MappableMobile

class CameraManagerImpl: CameraManager {
    // MARK: - Public properties

    var cameraMode: MMKCameraMode {
        get {
            camera.cameraMode()
        }
        set {
            camera.setCameraModeWith(newValue, animation: Const.animation)
        }
    }

    // MARK: - Constructor

    init(
        map: MMKMap,
        camera: MMKCamera,
        locationManager: LocationManager,
        settingsRepository: SettingsRepository
    ) {
        self.map = map
        self.camera = camera
        self.locationManager = locationManager
        self.settingsRepository = settingsRepository
    }

    // MARK: - Public properties

    func changeZoom(_ change: ZoomChange) {
        guard cameraMode != .following else {
            settingsRepository.zoomOffset.send(settingsRepository.zoomOffset.value + change.rawValue)
            return
        }

        map.move(
            with: MMKCameraPosition(
                target: map.cameraPosition.target,
                zoom: map.cameraPosition.zoom + change.rawValue,
                azimuth: map.cameraPosition.azimuth,
                tilt: map.cameraPosition.tilt
            ),
            animation: Const.animation
        )
    }

    func moveCameraToUserLocation() {
        guard let location = locationManager.location.value else {
            return
        }
        let cameraPosition = map.cameraPosition
        map.move(
            with: MMKCameraPosition(
                target: location.position,
                zoom: Const.mapDefaultZoom,
                azimuth: cameraPosition.azimuth,
                tilt: cameraPosition.tilt
            ),
            animation: Const.animation
        )
    }

    func start() {
        subscribeToFirstLocationObtained()
    }

    // MARK: - Private methods

    private func subscribeToFirstLocationObtained() {
        locationManager.location
            .compactMap { $0 }
            .filter { [weak self] _ in self?.isLocationUnknown ?? true }
            .sink { [weak self] _ in
                self?.isLocationUnknown = false
                self?.moveCameraToUserLocation()
            }
            .store(in: &cancellables)
    }

    // MARK: - Private properties

    private var isLocationUnknown = true

    private let map: MMKMap
    private let camera: MMKCamera
    private let locationManager: LocationManager
    private let settingsRepository: SettingsRepository

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Private nesting

    private enum Const {
        static let animation = MMKAnimation(type: .smooth, duration: 0.5)
        static let mapZoomStep: Float = 1.0
        static let mapDefaultZoom: Float = 15.0
    }
}
