//
//  RestDetailViewModel.swift
//  LeisurioApp
//
//  Created by Sosin Vladislav on 28.06.2023.
//

import SwiftUI

final class RestDetailViewModel: ObservableObject {
    @Published var preRestMood = 3
    @Published var postRestMood = 3
    @Published var finalRestMood = 3
    @Published var isSaved = false
    
    @Published var showToast: Bool = false
    @Published var toastMessage: String = ""
    @Published var toastImage: String = ""
    
    func getStatusText(from symbolName: String) -> String {
        switch symbolName {
        case "hourglass.bottomhalf.filled":
            return NSLocalizedString("Waiting", comment: "")
        case "hourglass":
            return NSLocalizedString("In progress", comment: "")
        case "hourglass.tophalf.filled":
            return NSLocalizedString("Finished", comment: "")
        default:
            return "Undefined"
        }
    }
    
    func updateMood(for index: Int, mood: Binding<Int>) {
        mood.wrappedValue = index
    }
    
    func updateRest(rest: Rest, preRestMood: Int, postRestMood: Int, finalRestMood: Int) async -> Rest? {
        do {
            let updatedRest = try await updateRest(
                restId: rest.restId,
                startDate: rest.startDate,
                endDate: rest.endDate,
                keyword: rest.keyword,
                restType: rest.restType,
                preRestMood: preRestMood,
                postRestMood: postRestMood,
                finalRestMood: finalRestMood,
                isRated: true
            )

            DispatchQueue.main.async {
                self.toastMessage = NSLocalizedString("Rate saved!", comment: "")
                self.toastImage = "checkmark.square"
                self.showToast = true
            }

            return updatedRest
        } catch {
            print("Failed to update rest: \(error)")
            return nil
        }
    }

    
    func toggleIsSaved() {
        isSaved = false
    }
    
    func updateRest(
        restId: String,
        startDate: Date,
        endDate: Date,
        keyword: String,
        restType: String,
        preRestMood: Int,
        postRestMood: Int,
        finalRestMood: Int,
        isRated: Bool
    ) async throws -> Rest {
        let updatedRest = Rest(
            restId: restId,
            startDate: startDate,
            endDate: endDate,
            keyword: keyword,
            restType: restType,
            preRestMood: preRestMood,
            postRestMood: postRestMood,
            finalRestMood: finalRestMood,
            isRated: isRated
        )

        do {
            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
            try await UserManager.shared.updateRestForUser(userId: authDataResult.uid, rest: updatedRest)
            print("Rest updated successfully")
        } catch {
            print("Failed to update rest: \(error)")
        }
        
        return updatedRest
    }
    
    func getHourglassSymbol(for rest: Rest) -> String {
        let now = Date()
        let start = rest.startDate
        let end = rest.endDate
        if start <= now && now <= end {
            return "hourglass"
        } else if now < start {
            return "hourglass.bottomhalf.filled"
        } else {
            return "hourglass.tophalf.filled"
        }
    }
}
