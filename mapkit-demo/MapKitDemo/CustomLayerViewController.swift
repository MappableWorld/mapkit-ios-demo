import UIKit
import MappableMobile

/**
 * This example shows how to add a user-defined layer to the map.
 * We use the UrlProvider class to format requests to a remote server that renders
 * tiles. For simplicity, we ignore map coordinates and zoom here, and
 * just provide a URL for the static image.
 */
class CustomLayerViewController: BaseMapViewController {

    var layer: MMKLayer?

    internal class CustomTilesUrlProvider: NSObject, MMKTilesUrlProvider {
        func formatUrl(with tileId: MMKTileId, version: MMKVersion, features: [String : String]) -> String {
            return Const.logoURL
        }
    }

    // Client code must retain strong references to providers and projection
    let tilesUrlProvider = CustomTilesUrlProvider()

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.mapWindow.map.mapType = .none

        let layerOptions = MMKLayerOptions(
            active: true,
            nightModeAvailable: true,
            cacheable: true,
            animateOnActivation: true,
            tileAppearingAnimationDuration: 0,
            overzoomMode: .enabled,
            transparent: false,
            versionSupport: false
        )

        mapView.mapWindow.map.addTileLayer(
            withLayerId: "mapkit_logo",
            layerOptions: layerOptions,
            createTileDataSource: {(builder: MMKTileDataSourceBuilder) in
                builder.setTileFormatWith(.png)
                builder.setTileUrlProviderWith(self.tilesUrlProvider)
                builder.setImageUrlProviderWith(MMKImagesDefaultUrlProvider())
            }
        )

    }
}
