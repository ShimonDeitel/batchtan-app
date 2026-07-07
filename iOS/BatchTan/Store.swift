import Foundation

@MainActor
final class BatchTanStore: ObservableObject {
    @Published private(set) var hides: [Hide] = []
    @Published private(set) var proEntries: [BTProEntry] = []

    static let freeLimit = 30

    private let fileURL: URL
    private let proFileURL: URL

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        self.fileURL = dir.appendingPathComponent("batchtan_hides.json")
        self.proFileURL = dir.appendingPathComponent("batchtan_pro.json")
        if ProcessInfo.processInfo.arguments.contains("-uiTestReset") {
            try? FileManager.default.removeItem(at: fileURL)
            try? FileManager.default.removeItem(at: proFileURL)
        }
        load()
        if hides.isEmpty {
            seedDefaults()
        }
        if proEntries.isEmpty {
            seedProDefaults()
        }
    }

    private func seedDefaults() {
        hides = [
            Hide(species: "Whitetail Deer", stage: "Salting", soakStart: Date(), notes: "Cape only"),
            Hide(species: "Coyote", stage: "Pickling", soakStart: Date(), notes: "Full body")
        ]
        save()
    }

    private func seedProDefaults() {
        proEntries = [
            BTProEntry(chemical: "Pickle Acid", ratio: "1oz per gal @ pH2", stage: "Pickling", durationHours: "48"),
            BTProEntry(chemical: "Tanning Oil", ratio: "1:1 with water", stage: "Tanning", durationHours: "24")
        ]
        saveProEntries()
    }

    func canAdd(isPro: Bool) -> Bool {
        isPro || hides.count < Self.freeLimit
    }

    @discardableResult
    func addHide(species: String, stage: String, soakStart: Date, notes: String, isPro: Bool) -> Bool {
        let trimmed = species.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, canAdd(isPro: isPro) else { return false }
        let item = Hide(species: species, stage: stage, soakStart: soakStart, notes: notes)
        hides.append(item)
        save()
        return true
    }

    func updateHide(_ id: UUID, species: String, stage: String, soakStart: Date, notes: String) {
        guard let idx = hides.firstIndex(where: { $0.id == id }) else { return }
        hides[idx].species = species
        hides[idx].stage = stage
        hides[idx].soakStart = soakStart
        hides[idx].notes = notes
        save()
    }

    func deleteHide(_ id: UUID) {
        hides.removeAll { $0.id == id }
        save()
    }

    func deleteAllData() {
        hides = []
        proEntries = []
        seedDefaults()
        seedProDefaults()
    }

    // MARK: - Pro entries

    @discardableResult
    func addProEntry(chemical: String, ratio: String, stage: String, durationHours: String) -> Bool {
        let entry = BTProEntry(chemical: chemical, ratio: ratio, stage: stage, durationHours: durationHours)
        proEntries.append(entry)
        saveProEntries()
        return true
    }

    func deleteProEntry(_ id: UUID) {
        proEntries.removeAll { $0.id == id }
        saveProEntries()
    }

    // MARK: - Persistence

    private struct Snapshot: Codable {
        var items: [Hide]
    }
    private struct ProSnapshot: Codable {
        var items: [BTProEntry]
    }

    private func load() {
        if let data = try? Data(contentsOf: fileURL), let decoded = try? JSONDecoder().decode(Snapshot.self, from: data) {
            hides = decoded.items
        }
        if let data = try? Data(contentsOf: proFileURL), let decoded = try? JSONDecoder().decode(ProSnapshot.self, from: data) {
            proEntries = decoded.items
        }
    }

    private func save() {
        let snapshot = Snapshot(items: hides)
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    private func saveProEntries() {
        let snapshot = ProSnapshot(items: proEntries)
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        try? data.write(to: proFileURL, options: .atomic)
    }
}
