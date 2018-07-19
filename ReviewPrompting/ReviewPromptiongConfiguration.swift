//
//  ReviewPromptiongConfiguration.swift
//  ReviewPrompting
//
//  Created by Adriaan on 19/7/18.
//  Copyright © 2018 Field Apps. All rights reserved.
//

import Foundation

struct ReviewPromptingConfiguration {

    let appName: String
    let shouldTriage: Bool

    let minDaysAfterCrash: Int
    let minDaysAfterNegativeTriage: Int
    let minDaysAfterPrompted: Int
    let minDaysAfterFirstLaunch: Int
    let minSessions: Int
}
