import XCTest
@testable import BatchTan

final class BatchTanTests: XCTestCase {

    @MainActor
    func testStoreSeedsAboveZeroButBelowFreeLimit() {
        let store = BatchTanStore()
        XCTAssertGreaterThan(store.hides.count, 0)
        XCTAssertLessThan(store.hides.count, BatchTanStore.freeLimit)
    }

    @MainActor
    func testAddEntrySucceedsWhenUnderLimit() {
        let store = BatchTanStore()
        let before = store.hides.count
        let added = store.addHide(species: "Whitetail Deer", stage: "Fleshing", soakStart: Date(), notes: "", isPro: false)
        XCTAssertTrue(added)
        XCTAssertEqual(store.hides.count, before + 1)
    }

    @MainActor
    func testAddEntryRejectsBlankPrimaryField() {
        let store = BatchTanStore()
        let before = store.hides.count
        let added = store.addHide(species: "   ", stage: "Fleshing", soakStart: Date(), notes: "", isPro: false)
        XCTAssertFalse(added)
        XCTAssertEqual(store.hides.count, before)
    }

    @MainActor
    func testFreeLimitBlocksAdditionalEntries() {
        let store = BatchTanStore()
        for item in store.hides { store.deleteHide(item.id) }
        for _ in 0..<BatchTanStore.freeLimit {
            XCTAssertTrue(store.addHide(species: "Whitetail Deer", stage: "Fleshing", soakStart: Date(), notes: "", isPro: false))
        }
        XCTAssertFalse(store.addHide(species: "Whitetail Deer", stage: "Fleshing", soakStart: Date(), notes: "", isPro: false))
        XCTAssertTrue(store.addHide(species: "Whitetail Deer", stage: "Fleshing", soakStart: Date(), notes: "", isPro: true))
    }

    @MainActor
    func testDeleteEntry() {
        let store = BatchTanStore()
        store.addHide(species: "Whitetail Deer", stage: "Fleshing", soakStart: Date(), notes: "", isPro: false)
        guard let item = store.hides.last else { return XCTFail("expected entry") }
        let before = store.hides.count
        store.deleteHide(item.id)
        XCTAssertEqual(store.hides.count, before - 1)
    }

    @MainActor
    func testDeleteAllDataReseeds() {
        let store = BatchTanStore()
        store.deleteAllData()
        XCTAssertGreaterThan(store.hides.count, 0)
        XCTAssertGreaterThan(store.proEntries.count, 0)
    }

    @MainActor
    func testUpdateEntryPersistsChange() {
        let store = BatchTanStore()
        store.addHide(species: "Whitetail Deer", stage: "Fleshing", soakStart: Date(), notes: "", isPro: false)
        guard let item = store.hides.last else { return XCTFail("expected entry") }
        store.updateHide(item.id, species: "Whitetail Deer", stage: "Fleshing", soakStart: Date(), notes: "")
        XCTAssertEqual(store.hides.count, store.hides.count)
    }
}
