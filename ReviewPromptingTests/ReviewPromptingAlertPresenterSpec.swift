//
//  ReviewPromptingAlertPresenterSpec.swift
//  ReviewPromptingTests
//
//  Created by Adriaan on 20/7/18.
//  Copyright © 2018 Field Apps. All rights reserved.
//

import UIKit
import Quick
import Nimble
@testable import ReviewPrompting

class ReviewPromptingAlertPresenterSpec: QuickSpec {

    override func spec() {

        describe("ReviewPromptingAlertPresenter") {

            describe("presentOn") {

                context("with triage") {

                    it("presents a triage alert") {

                        let viewController = UIViewController()
                        let window = UIWindow()
                        window.rootViewController = viewController
                        window.isHidden = false

                        let presenter = ReviewPromptingAlertPresenter()
                        let configuration = ReviewPromptingConfiguration(appName: "app", shouldTriage: true, isPromptingEnabled: true, minDaysAfterCrash: 0, minDaysAfterNegativeTriage: 0, minDaysAfterPrompted: 0, minDaysAfterFirstLaunch: 0, minSessions: 0)
                        presenter.presentOn(viewController: viewController, withConfiguration: configuration)

                        expect(viewController.presentedViewController).toEventually(beAKindOf(UIAlertController.self), timeout: 1)

                        window.rootViewController = nil
                    }
                }
            }
        }
    }
}
