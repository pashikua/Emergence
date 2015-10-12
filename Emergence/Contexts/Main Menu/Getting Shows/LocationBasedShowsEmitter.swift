import UIKit

class LocationBasedShowEmitter: NSObject, ShowEmitter {
    let network: ArtsyProvider<ArtsyAPI>
    let location: Location
    let title: String
    var networking = false

    init(location:Location, network: ArtsyProvider<ArtsyAPI>) {
        self.network = network
        self.location = location
        self.title = location.name
    }

    var updateBlock: ((shows:[Show]) -> ())?
    func onUpdate( callback: (shows:[Show]) -> () ) {
        updateBlock = callback
    }

    var shows:[Show] = [] {
        didSet {
            updateBlock?(shows: shows)
        }
    }

    func showAtIndexPath(index: NSIndexPath) -> Show {
        let showIndex = index.row
        return shows[showIndex]
    }

    var numberOfShows: Int {
        return shows.count
    }

    func getShows() {
        if networking { return }
        networking = true

        let coords = location.coordinates()
        let showInfo = ArtsyAPI.RunningShowsNearLocation(amount: 25, lat: coords.lat, long: coords.long)

        network.request(showInfo).mapSuccessfulHTTPToObjectArray(Show).subscribe(next: { shows in

            self.shows = shows

            }, error: { error in
                print("ERROROR \(error)")
            }, completed: nil, disposed: nil)
    }
}