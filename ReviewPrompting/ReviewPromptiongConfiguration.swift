//
//  ReviewPromptiongConfiguration.swift
//  ReviewPrompting
//
//  Created by Adriaan on 19/7/18.
//  Copyright © 2018 Field Apps. All rights reserved.
//

import Foundation

public struct ReviewPromptingConfiguration {

    let appName: String
    let shouldTriage: Bool

    let minDaysAfterCrash: Int
    let minDaysAfterNegativeTriage: Int
    let minDaysAfterPrompted: Int
    let minDaysAfterFirstLaunch: Int
    let minSessions: Int

    public init(
        appName: String,
        shouldTriage: Bool,
        minDaysAfterCrash: Int,
        minDaysAfterNegativeTriage: Int,
        minDaysAfterPrompted: Int,
        minDaysAfterFirstLaunch: Int,
        minSessions: Int
        ) {
        self.appName = appName
        self.shouldTriage = shouldTriage
        self.minDaysAfterCrash = minDaysAfterCrash
        self.minDaysAfterNegativeTriage = minDaysAfterNegativeTriage
        self.minDaysAfterPrompted = minDaysAfterPrompted
        self.minDaysAfterFirstLaunch = minDaysAfterFirstLaunch
        self.minSessions = minSessions
    }
}
