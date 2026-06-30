//
//  RepositoryProtocols.swift
//  MediStock
//
//  Created by Jaouad on 29/06/2026.
//

import Foundation

// MARK: - MedicineRepository
protocol MedicineRepository {
    // Recup tous les médocs
    func fetchMedicines() async throws -> [Medicine]
    // Ajout un médoc et le retroune avec l'id généré
    func addMedicine(_ medicine: Medicine) async throws -> Medicine
    // MAJ un médoc existant
    func updateMedicine(_ medicine: Medicine) async throws

    func deleteMedicine(_ medicine: Medicine) async throws
}

// MARK: - HistoryRepository
protocol HistoryRepository {
    // Recup l'historique d'un medo donné
    func fetchHistory(forMedicineId medicineId: String) async throws -> [HistoryEntry]
    // Ajoute une entrée d'historique.
    func addEntry(_ entry: HistoryEntry) async throws
}
