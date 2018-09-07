//
//  ReviewPromptiongConfiguration.swift
//  ReviewPrompting
//
//  Created by Adriaan on 19/7/18.
//  Copyright © 2018 Field Apps. All rights reserved.
//

import Foundation

public struct ReviewPromptingConfiguration {

    public let appName: String
    public let shouldTriage: Bool

    public let minDaysAfterCrash: Int
    public let minDaysAfterNegativeTriage: Int
    public let minDaysAfterPrompted: Int
    public let minDaysAfterFirstLaunch: Int
    public let minSessions: Int
}
