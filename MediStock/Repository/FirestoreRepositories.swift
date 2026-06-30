//
//  FirestoreRepositories.swift
//  MediStock
//
//  Created by Jaouad on 29/06/2026.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

// MARK: - FirestoreMedicineRepository
final class FirestoreMedicineRepository: MedicineRepository {

    private let collection = Firestore.firestore().collection("medicines")

    // MARK: Lecture
    func fetchMedicines() async throws -> [Medicine] {
        let snapshot = try await collection.getDocuments()
        // les docs mal formés sont ignorés plutôt que  faire échouer tout le chargement.
        return snapshot.documents.compactMap{try? $0.data(as: Medicine.self)}
    }
    // MARK: Ecriture
    func addMedicine(_ medicine: Medicine) async throws -> Medicine {
        // addDocument(from:) applique l'écriture au cache local immédiatement, puis synchronise.
        let reference = try collection.addDocument(from: medicine)
        var saved = medicine
        saved.id = reference.documentID
        return saved
    }
    func updateMedicine(_ medicine: Medicine) async throws {
        guard let id = medicine.id else {
            throw AppError.invalidData("Medicament dans indentifiant.")
        }
        try collection.document(id).setData(from: medicine)
    }
    func deleteMedicine(_ medicine: Medicine) async throws  {
        guard let id = medicine.id else {
            throw AppError.invalidData("Medicament dans indentifiant.")
        }
        try await collection.document(id).delete()
    }
}
// MARK: - FirestoreHistoryRepository


final class FirestoreHistoryRepository: HistoryRepository {

    private let collection = Firestore.firestore().collection("history")

    func fetchHistory(forMedicineId medicineId: String) async throws -> [HistoryEntry] {
        let snapshot = try await collection
            .whereField("medicineId", isEqualTo: medicineId)
            .getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: HistoryEntry.self) }
    }

    func addEntry(_ entry: HistoryEntry) async throws {
        _ = try collection.addDocument(from: entry)
    }
}
