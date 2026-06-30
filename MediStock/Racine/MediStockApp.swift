//
//  MediStockApp.swift
//  MediStock
//
//  Created by Vincent Saluzzo on 28/05/2024.
//

import SwiftUI

@main
struct MediStockApp: App {

    // MARK: Délégué Firebase
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    // MARK: Dépendances globales (instances uniques)

    // SessionStore reste un ObservableObject classique → @StateObject + .environmentObject.
    @StateObject private var sessionStore = SessionStore()

    // MedicineStockViewModel est @Observable → @State + .environment(_:).
    @State private var medicineStockViewModel = MedicineStockViewModel(
        medicineRepository: FirestoreMedicineRepository(),
        historyRepository: FirestoreHistoryRepository()
    )
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sessionStore)
                .environment(medicineStockViewModel)
        }
    }
}
