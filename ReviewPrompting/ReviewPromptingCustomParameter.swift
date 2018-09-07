//
//  ReviewPromptingCustomParameter.swift
//  ReviewPrompting
//
//  Created by Adriaan on 19/7/18.
//  Copyright © 2018 Field Apps. All rights reserved.
//

import Foundation

public struct ReviewPromptingCustomParameter {

    let name: String
    let threshold: Int

    public init(name: String, threshold: Int) {
        self.name = name
        self.threshold = threshold
    }
}
