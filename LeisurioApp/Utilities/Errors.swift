//
//  Errors.swift
//  LeisurioApp
//
//  Created by Vladislav Sosin on 30.07.2023.
//

import Foundation

enum GoogleAppleError: LocalizedError {
    case accountAlreadyExists
    case noAccountExists
    
    var errorDescription: String? {
        switch self {
        case .accountAlreadyExists:
            return "An account with this email already exists!"
        case .noAccountExists:
            return "No account exists with this email!"
        }
    }
}

enum SignInError: LocalizedError {
    case loginDetailsNil
    case userNotFound
    case wrongPassword
    case unknownError
    case badEmail
    case notVerified
    case shortPassword

    var errorDescription: String? {
        switch self {
        case .userNotFound:
            return "The account does not exist!"
        case .wrongPassword:
            return "The email or password is incorrect!"
        case .unknownError:
            return "An unknown error occurred!"
        case .loginDetailsNil:
            return "Email & password couldn`t be empty!"
        case .badEmail:
            return "Invalid Email address!"
        case .shortPassword:
            return "The password should be at least 8 characters!"
        case .notVerified:
            return "An email has been sent to your registered email address with a verification link to confirm your account."
        }
    }
}

enum SignUpError: LocalizedError {
    case emailAlreadyInUse
    case invalidEmail
    case shortPassword
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .emailAlreadyInUse:
            return "This email is already in use!"
        case .invalidEmail:
            return "Invalid email format!"
        case .unknownError:
            return "An unknown error occurred!"
        case .shortPassword:
            return "The password should be at least 8 characters!"
        }
    }
}
