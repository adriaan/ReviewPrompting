//
//  ReviewPromptingParameterPersistor.swift
//  ReviewPrompting
//
//  Created by Adriaan on 19/7/18.
//  Copyright © 2018 Field Apps. All rights reserved.
//

import Foundation

struct ReviewPromptingParameterPersistor {

    private let userDefaults = UserDefaults.standard

    //MARK: - Counter values

    func increment(parameter: String) {
        let currentValue = userDefaults.integer(forKey: parameter)
        userDefaults.set(currentValue + 1, forKey: parameter)
    }

    func set(value: Int, forParameter parameter: String) {
        userDefaults.set(value, forKey: parameter)
    }

    func valueFor(parameter: String) -> Int {
        return userDefaults.integer(forKey: parameter)
    }

    //MARK: - Date values

    func set(date: Date, forParameter parameter: String) {
        userDefaults.set(date, forKey: parameter)
    }

    func dateFor(parameter: String) -> Date? {
        return userDefaults.object(forKey: parameter) as? Date
    }

    //MARK: - Prompted date values

    func setLastPromptedDate(date: Date) {
        var lastPromptedDates = userDefaults.object(forKey: ReviewPromptingDefaultParameters.lastPromptedDate.rawValue) as? [Date] ?? []
        lastPromptedDates.append(date)
        if lastPromptedDates.count > 3 {
            lastPromptedDates = Array(lastPromptedDates.dropFirst())
        }
        userDefaults.set(lastPromptedDates, forKey: ReviewPromptingDefaultParameters.lastPromptedDate.rawValue)
    }

    func promptedDates() -> [Date] {
        return userDefaults.object(forKey: ReviewPromptingDefaultParameters.lastPromptedDate.rawValue) as? [Date] ?? []
    }
}
