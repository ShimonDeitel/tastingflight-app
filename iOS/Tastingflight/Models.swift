import Foundation

struct WhiskeyEntry: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var rating: Int = 3
    var dateAdded: Date = Date()
    var distillery: String
    var age: Double
    var region: String
    var notes: String

    init(id: UUID = UUID(), title: String, rating: Int = 3, dateAdded: Date = Date(), distillery: String = "", age: Double = 0, region: String = "", notes: String = "") {
        self.id = id
        self.title = title
        self.rating = rating
        self.dateAdded = dateAdded
        self.distillery = distillery
        self.age = age
        self.region = region
        self.notes = notes
    }
}
