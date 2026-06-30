//
//  AppError.swift
//  MediStock
//
//  Created by Jaouad on 29/06/2026.
//

import Foundation

// MARK: - AppError

/// Erreurs métier de l'application, présentables directement à l'utilisateur.
/// Centralise tous les cas d'échec pour une gestion d'erreur cohérente (carte A4)
enum AppError : LocalizedError {
    case notAuthenticated
    case invalidData(String)
    case fetchFailed
    case saveFailed
    case unknown(Error)

    // MARK: Message utilisateur

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "Vous devez être connecté pour effectuer cette action"
        case .invalidData(let reason):
            return "Données invalides : \(reason)"
        case .fetchFailed:
            return "Impossible de charger les données. Veuillez réessayer."
        case .saveFailed:
            return "L'enregistrement à échoué. Veuillez réessayer."
        case .unknown(let error):
            return error.localizedDescription
        }
    }
    // MARK: Conversion
    /// Convertit n'importe quelle erreur en AppError, pour un affichage homogène.
    static func map(_ error: Error) -> AppError {
        (error as? AppError) ?? .unknown(error)
    }
}
