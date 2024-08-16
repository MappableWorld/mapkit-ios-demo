//
//  RoutingViewModel.swift
//  MapRouting
//

import UIKit
import MappableMobile

final class RoutingViewModel {
    // MARK: - Public properties

    private(set) var routePoints: [MMKPoint] = [] {
        didSet {
            onRoutingPointsUpdated()
        }
    }
    private(set) var routes: [MMKDrivingRoute] = [] {
        didSet {
            onRoutesUpdated()
        }
    }

    var placemarksCollection: MMKMapObjectCollection!
    var routesCollection: MMKMapObjectCollection!

    // MARK: - Constructor

    init(controller: UIViewController) {
        self.controller = controller
    }

    // MARK: - Public methods

    func addRoutePoint(_ point: MMKPoint) {
        routePoints.append(point)
    }

    func resetRoutePoints() {
        routePoints.removeAll()
    }

    // MARK: - Private methods

    private func onRoutingPointsUpdated() {
        placemarksCollection.clear()

        if routePoints.isEmpty {
            drivingSession?.cancel()
            routes = []
            return
        }

        let image = UIImage(systemName: "circle.circle.fill")!
        let iconStyle = MMKIconStyle()
        iconStyle.scale = 0.5
        iconStyle.zIndex = 20.0

        routePoints.forEach {
            let placemark = placemarksCollection.addPlacemark()
            placemark.geometry = $0
            placemark.setIconWith(image, style: iconStyle)
        }

        if routePoints.count < 2 {
            return
        }

        let requestPoints =
            [
                MMKRequestPoint(
                    point: routePoints.first!,
                    type: .waypoint,
                    pointContext: nil,
                    drivingArrivalPointId: nil
                )
            ] +
            routePoints[1..<routePoints.count - 1]
            .map { MMKRequestPoint(point: $0, type: .viapoint, pointContext: nil, drivingArrivalPointId: nil) } +
            [
                MMKRequestPoint(
                    point: routePoints.last!,
                    type: .waypoint,
                    pointContext: nil,
                    drivingArrivalPointId: nil
                )
            ]

        let drivingOptions = MMKDrivingOptions()
        let vehicleOptions = MMKDrivingVehicleOptions()

        drivingSession = drivingRouter.requestRoutes(
            with: requestPoints,
            drivingOptions: drivingOptions,
            vehicleOptions: vehicleOptions,
            routeHandler: drivingRouteHandler
        )
    }

    private func onRoutesUpdated() {
        routesCollection.clear()
        if routes.isEmpty {
            return
        }

        routes.enumerated()
            .forEach { pair in
                let routePolyline = routesCollection.addPolyline(with: pair.element.geometry)
                if pair.offset == 0 {
                    routePolyline.styleMainRoute()
                } else {
                    routePolyline.styleAlternativeRoute()
                }
            }
    }

    private func drivingRouteHandler(drivingRoutes: [MMKDrivingRoute]?, error: Error?) {
        if let error = error {
            switch error {
            case _ as MRTNetworkError:
                AlertPresenter.present(from: controller, with: "Routes request error due network issues")

            default:
                AlertPresenter.present(from: controller, with: "Routes request unknown error")
            }
            return
        }

        guard let drivingRoutes = drivingRoutes else {
            return
        }

        routes = drivingRoutes
    }

    // MARK: - Private properties

    private lazy var drivingRouter: MMKDrivingRouter = MMKDirectionsFactory.instance().createDrivingRouter(
        withType: .combined
    )
    private var drivingSession: MMKDrivingSession?

    private weak var controller: UIViewController?
}
