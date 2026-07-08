import Foundation

struct Hide: Identifiable, Codable, Equatable {
    let id: UUID
    var species: String
    var stage: String
    var soakStart: Date
    var notes: String
    var createdDate: Date

    init(id: UUID = UUID(), species: String = "Whitetail Deer", stage: String = "Fleshing", soakStart: Date = Date(), notes: String = "", createdDate: Date = Date()) {
        self.id = id
        self.species = species
        self.stage = stage
        self.soakStart = soakStart
        self.notes = notes
        self.createdDate = createdDate
    }
}

/// Pro bonus feature entry: Stage Countdown Timers.
struct BTProEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var chemical: String
    var ratio: String
    var stage: String
    var durationHours: String
    var createdDate: Date

    init(id: UUID = UUID(), chemical: String = "Pickle Acid", ratio: String = "1oz per gal @ pH2", stage: String = "Pickling", durationHours: String = "48", createdDate: Date = Date()) {
        self.id = id
        self.chemical = chemical
        self.ratio = ratio
        self.stage = stage
        self.durationHours = durationHours
        self.createdDate = createdDate
    }
}

enum BTStageOption {
    static let all = ["Fleshing", "Salting", "Pickling", "Tanning", "Softening", "Complete"]
}
