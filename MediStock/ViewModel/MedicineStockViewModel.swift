import Foundation
import Observation

/// /// Utilise la macro @Observable (iOS 17+) .
/// Instance unique injectée via l'environnement, dépendante de protocoles Repository (testable).

@MainActor
@Observable
final class MedicineStockViewModel {

    // MARK: - Observables

    var medicines: [Medicine] = []
    var aisles: [String] = []
    var history: [HistoryEntry] = []
    var errorMessage: String?
    var isLoading: Bool = false

    // MARK: Dépendances injectées
    @ObservationIgnored private let medicineRepository: MedicineRepository
    @ObservationIgnored private let historyRepository: HistoryRepository

    // Init
    init(medicineRepository: MedicineRepository,
         historyRepository: HistoryRepository) {
        self.medicineRepository = medicineRepository
        self.historyRepository = historyRepository
    }
    // MARK: - Lecture

    /// Charge les médicaments et en déduit la liste des rayons (lecture one-shot async).
    func loadMedicines() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let fetched = try await medicineRepository.fetchMedicines()
            medicines = fetched
            aisles = Array(Set(fetched.map { $0.aisle})).sorted()
        } catch {
            errorMessage = AppError.map(error).errorDescription
        }
    }
    /// Conservé pour compatibilité avec les vues : déclenche un chargement.
    func fetchMedicines() {
        Task { await loadMedicines()}
    }

    /// Conservé pour compatibilité : les rayons sont déduits du même chargement.
    func fetchAisles() {
        Task{ await loadMedicines()}
    }

    /// Charge l'historique d'un médoc donné
    func fetchHistory(for medicine: Medicine) {
        guard let id = medicine.id else { return}
        Task {
            do {
                history = try await historyRepository.fetchHistory(forMedicineId: id)
            } catch {
                errorMessage = AppError.map(error).errorDescription
            }
        }
    }
    // MARK: - Ecriture
    /// temporaire, à rempalcer par un écran de création B1
    func addRandomMedicine(user: String) {
        let medicine = Medicine(name: "Medicine \(Int.random(in: 1...100))",
                                stock: Int.random(in: 1...100),
                                aisle: "Aisle \(Int.random(in: 1...10))")
        Task{
        do {
            let saved = try await medicineRepository.addMedicine(medicine)
            medicines.append(saved)
            aisles = Array(Set(medicines.map {$0.aisle})).sorted()
            await addHistory(action: "Added\(saved.name)",
                             user: user,
                             medicineId: saved.id ?? "",
                             details: "Added new medicine")
        } catch {
            errorMessage = AppError.map(error).errorDescription
        }
    }
    }

    func deleteMedicines(at offsets: IndexSet) {
        let toDelete = offsets.map { medicines[$0]}
        Task {
            for medicine in toDelete {
                do {
                    try await medicineRepository.deleteMedicine(medicine)
                    medicines.removeAll{ $0.id == medicine.id}
                } catch {
                    errorMessage = AppError.map(error).errorDescription
                }
            }
        }
    }

    func increaseStock(_ medicine: Medicine, user: String) {
        updateStock(medicine, by: 1, user: user)
    }

    func decreaseStock(_ medicine: Medicine, user: String) {
        updateStock(medicine, by: -1, user: user)
    }

    private func updateStock(_ medicine: Medicine, by amount: Int, user: String) {
        guard let id = medicine.id else { return }
        let oldStock = medicine.stock
        let newStock = medicine.stock + amount
        var updated = medicine
        updated.stock = newStock
        Task {
            do {
                try await medicineRepository.updateMedicine(updated)
                // Mise à jour locale optimisé pour un retour immédiat à l'écran
                if let index = medicines.firstIndex(where: {$0.id == id }) {
                    medicines[index].stock = newStock
                }
                let verb = amount > 0 ? "Increased" : "Decreased"
                await addHistory(action: "\(verb) stock of \(medicine.name) by \(amount)",
                                 user: user,
                                 medicineId: id,
                                 details: "Stock changed from \(oldStock) to \(newStock)")
            } catch {
                errorMessage = AppError.map(error).errorDescription
            }
        }

    }

    func updateMedicine(_ medicine: Medicine, user: String)  {
        guard let id = medicine.id else { return }
        Task {
        do {
            try await medicineRepository.updateMedicine(medicine)
            if let index = medicines.firstIndex(where: {$0.id == id}){
                medicines[index] = medicine
            }
            await addHistory(action: "Updated \(medicine.name)",
                             user: user,
                             medicineId: id,
                             details: "Updated medicine details")
        } catch {
            errorMessage = AppError.map(error).errorDescription
        }
    }
    }

    // MARK: - Historique
    private func addHistory(action: String, user: String, medicineId: String, details: String) async {
        let entry = HistoryEntry(medicineId: medicineId, user: user, action: action, details: details)
        do {
            try await historyRepository.addEntry(entry)
        } catch  {
            errorMessage = AppError.map(error).errorDescription
        }
    }


}
