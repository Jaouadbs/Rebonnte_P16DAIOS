//
//  MedicineStockViewModelTests.swift
//  MediStockTests
//
//  Created by Jaouad on 30/06/2026.
//

import XCTest
@testable import MediStock

@MainActor
final class MedicineStockViewModelTests: XCTestCase {

    // MARK: loadMedicines

    func test_loadMedicines_onSuccess_loadsMedicines() async {
        // Given : un repository contenant 3 médicaments
        let medicines = [
            Medicine(id: "1", name: "Doliprane", stock: 10, aisle: "Rayon A"),
            Medicine(id: "2", name: "Advil", stock: 5, aisle: "Rayon A"),
            Medicine(id: "3", name: "Smecta", stock: 8, aisle: "Rayon B")
        ]
        let sut = makeSUT(medicines: medicines)

        // When : on charge les médicaments
        await sut.loadMedicines()

        // Then : les 3 médicaments sont chargés, aucune erreur, chargement terminé
        XCTAssertEqual(sut.medicines.count, 3)
        XCTAssertEqual(sut.medicines.map { $0.name }, ["Doliprane", "Advil", "Smecta"])
        XCTAssertNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
    }

    func test_loadMedicines_derivesUniqueSortedAisles() async {
        // Given : des médicaments répartis sur des rayons, avec un rayon en double
        let medicines = [
            Medicine(id: "1", name: "A", stock: 1, aisle: "Rayon B"),
            Medicine(id: "2", name: "B", stock: 1, aisle: "Rayon A"),
            Medicine(id: "3", name: "C", stock: 1, aisle: "Rayon B")
        ]
        let sut = makeSUT(medicines: medicines)

        // When
        await sut.loadMedicines()

        // Then : les rayons sont dédupliqués et triés par ordre alphabétique
        XCTAssertEqual(sut.aisles, ["Rayon A", "Rayon B"])
    }

    func test_loadMedicines_whenEmpty_leavesStateEmpty() async {
        // Given : un repository sans aucun médicament
        let sut = makeSUT(medicines: [])

        // When
        await sut.loadMedicines()

        // Then : médicaments et rayons vides, aucune erreur
        XCTAssertTrue(sut.medicines.isEmpty)
        XCTAssertTrue(sut.aisles.isEmpty)
        XCTAssertNil(sut.errorMessage)
    }

    // MARK: - Helpers

    /// Fabrique le ViewModel sous test (SUT) avec des repositories mockés.
    private func makeSUT(medicines: [Medicine] = [],
                         history: [HistoryEntry] = []) -> MedicineStockViewModel {
        let medicineRepository = MockMedicineRepository(medicines: medicines)
        let historyRepository = MockHistoryRepository(entries: history)
        return MedicineStockViewModel(medicineRepository: medicineRepository,
                                      historyRepository: historyRepository)
    }
}
