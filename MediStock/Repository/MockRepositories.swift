//
//  MockRepositories.swift
//  MediStock
//
//  Created by Jaouad on 29/06/2026.
//

import Foundation
// MARK: - Données d'exemple

/// Jeu de données factice partagé par les mocks (tests et previews).
enum MockData {

    static let medicines: [Medicine] = [
        Medicine(id: "med-1", name: "Doliprane", stock: 12, aisle: "Rayon A"),
        Medicine(id: "med-2", name: "Advil", stock: 4, aisle: "Rayon A"),
        Medicine(id: "med-3", name: "Smecta", stock: 25, aisle: "Rayon B")
    ]

    static let history: [HistoryEntry] = [
        HistoryEntry(id: "h-1", medicineId: "med-1", user: "jaouad@gmail.com",
                     action: "Stock augmenté", details: "11 → 12", timestamp: Date())
    ]
}

// MARK: - MockMedicineRepository

/// Repository de médicaments en mémoire, sans Firebase.
final class MockMedicineRepository: MedicineRepository {

    private(set) var medicines: [Medicine]
    /// Si défini, toutes les méthodes lèvent cette erreur (pour tester les cas d'échec).
    var errorToThrow: Error?

    init(medicines: [Medicine] = MockData.medicines) {
        self.medicines = medicines
    }

    func fetchMedicines() async throws -> [Medicine] {
        if let errorToThrow { throw errorToThrow }
        return medicines
    }

    func addMedicine(_ medicine: Medicine) async throws -> Medicine {
        if let errorToThrow { throw errorToThrow }
        var saved = medicine
        saved.id = medicine.id ?? UUID().uuidString
        medicines.append(saved)
        return saved
    }

    func updateMedicine(_ medicine: Medicine) async throws {
        if let errorToThrow { throw errorToThrow }
        if let index = medicines.firstIndex(where: { $0.id == medicine.id }) {
            medicines[index] = medicine
        }
    }

    func deleteMedicine(_ medicine: Medicine) async throws {
        if let errorToThrow { throw errorToThrow }
        medicines.removeAll { $0.id == medicine.id }
    }
}

// MARK: - MockHistoryRepository

/// Repository d'historique en mémoire, sans Firebase.
final class MockHistoryRepository: HistoryRepository {

    private(set) var entries: [HistoryEntry]
    var errorToThrow: Error?

    init(entries: [HistoryEntry] = MockData.history) {
        self.entries = entries
    }

    func fetchHistory(forMedicineId medicineId: String) async throws -> [HistoryEntry] {
        if let errorToThrow { throw errorToThrow }
        return entries.filter { $0.medicineId == medicineId }
    }

    func addEntry(_ entry: HistoryEntry) async throws {
        if let errorToThrow { throw errorToThrow }
        entries.append(entry)
    }
}
