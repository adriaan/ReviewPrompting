//
//  ReviewPromptingCoordinatorSpec.swift
//  ReviewPromptingTests
//
//  Created by Adriaan on 20/7/18.
//  Copyright © 2018 Field Apps. All rights reserved.
//

import Quick
import Nimble
@testable import ReviewPrompting

class ReviewPromptingCoordinatorSpec: QuickSpec {

    override func spec() {

        describe("ReviewPromptingCoordinator") {

            var persistor: ReviewPromptingParameterPersistor!
            var presenter: ReviewPromptingAlertPresenter!

            beforeEach {
                persistor = ReviewPromptingParameterPersistor()
                presenter = ReviewPromptingAlertPresenter()
            }

            afterEach {
                UserDefaults.standard.dictionaryRepresentation().forEach({ (key, _) in
                    UserDefaults.standard.removeObject(forKey: key)
                })
            }

            describe("appDidCrash") {

                it("persists the crash date") {

                    let configuration = ReviewPromptingConfiguration(appName: "app", shouldTriage: true, isPromptingEnabled: true, minDaysAfterCrash: 5, minDaysAfterNegativeTriage: 10, minDaysAfterPrompted: 20, minDaysAfterFirstLaunch: 5, minSessions: 5)
                    let coordinator = ReviewPromptingCoordinator(configuration: configuration, customParameters: [], persistor: persistor, presenter: presenter)

                    coordinator.appDidCrash()

                    expect(persistor.dateFor(parameter: ReviewPromptingDefaultParameters.lastCrashDate.rawValue)!.timeIntervalSinceNow).to(beCloseTo(0, within: 0.01))
                }
            }

            describe("incrementCustomParameterWith") {

                context("when parameter is registered") {

                    it("persists the incremented parameter") {

                        let configuration = ReviewPromptingConfiguration(appName: "app", shouldTriage: true, isPromptingEnabled: true, minDaysAfterCrash: 5, minDaysAfterNegativeTriage: 10, minDaysAfterPrompted: 20, minDaysAfterFirstLaunch: 5, minSessions: 5)
                        let parameter = ReviewPromptingCustomParameter(name: "parameter", threshold: 10)
                        let coordinator = ReviewPromptingCoordinator(configuration: configuration, customParameters: [parameter], persistor: persistor, presenter: presenter)

                        coordinator.incrementCustomParameterWith(name: "parameter")
                        expect(persistor.valueFor(parameter: "parameter")) ==  1

                        coordinator.incrementCustomParameterWith(name: "parameter")
                        expect(persistor.valueFor(parameter: "parameter")) ==  2
                    }
                }

                context("when parameter is not registered") {

                    it("does not increment the parameter") {

                        let configuration = ReviewPromptingConfiguration(appName: "app", shouldTriage: true, isPromptingEnabled: true, minDaysAfterCrash: 5, minDaysAfterNegativeTriage: 10, minDaysAfterPrompted: 20, minDaysAfterFirstLaunch: 5, minSessions: 5)
                        let coordinator = ReviewPromptingCoordinator(configuration: configuration, customParameters: [], persistor: persistor, presenter: presenter)

                        coordinator.incrementCustomParameterWith(name: "parameter")
                        expect(persistor.valueFor(parameter: "parameter")) ==  0
                    }
                }
            }

            describe("set value for custom parameter") {

                context("when parameter is registered") {

                    it("persists the value for the parameter") {

                        let configuration = ReviewPromptingConfiguration(appName: "app", shouldTriage: true, isPromptingEnabled: true, minDaysAfterCrash: 5, minDaysAfterNegativeTriage: 10, minDaysAfterPrompted: 20, minDaysAfterFirstLaunch: 5, minSessions: 5)
                        let parameter = ReviewPromptingCustomParameter(name: "parameter", threshold: 10)
                        let coordinator = ReviewPromptingCoordinator(configuration: configuration, customParameters: [parameter], persistor: persistor, presenter: presenter)

                        coordinator.setValue(100, forCustomParameterWithName: "parameter")
                        expect(persistor.valueFor(parameter: "parameter")) ==  100
                    }
                }

                context("when parameter is not registered") {

                    it("does not persist the value for the parameter") {

                        let configuration = ReviewPromptingConfiguration(appName: "app", shouldTriage: true, isPromptingEnabled: true, minDaysAfterCrash: 5, minDaysAfterNegativeTriage: 10, minDaysAfterPrompted: 20, minDaysAfterFirstLaunch: 5, minSessions: 5)
                        let coordinator = ReviewPromptingCoordinator(configuration: configuration, customParameters: [], persistor: persistor, presenter: presenter)

                        coordinator.setValue(100, forCustomParameterWithName: "parameter")
                        expect(persistor.valueFor(parameter: "parameter")) ==  0
                    }
                }
            }

            describe("promptIfUserQualifies") {

                var fakePresenter: FakeReviewPromptingPresenter!
                beforeEach {
                    fakePresenter = FakeReviewPromptingPresenter()
                }

                it("does not call presenter if user doesn't qualify for minDaysAfterFirstLaunch") {

                    let configuration = ReviewPromptingConfiguration(appName: "app", shouldTriage: true, isPromptingEnabled: true, minDaysAfterCrash: 0, minDaysAfterNegativeTriage: 0, minDaysAfterPrompted: 0, minDaysAfterFirstLaunch: 10, minSessions: 0)
                    let coordinator = ReviewPromptingCoordinator(configuration: configuration, customParameters: [], persistor: persistor, presenter: fakePresenter)
                    // Force persist a first launch date.
                    forcePersistFirstLaunchDate(Date(), persistor: persistor)

                    coordinator.promptIfUserQualifiesOn(viewController: UIViewController())
                    expect(fakePresenter.presentOnCalled) == false
                }

                it("does not call presenter if user doesn't qualify for minSessions") {

                    let configuration = ReviewPromptingConfiguration(appName: "app", shouldTriage: true, isPromptingEnabled: true, minDaysAfterCrash: 0, minDaysAfterNegativeTriage: 0, minDaysAfterPrompted: 0, minDaysAfterFirstLaunch: 0, minSessions: 10)
                    let coordinator = ReviewPromptingCoordinator(configuration: configuration, customParameters: [], persistor: persistor, presenter: fakePresenter)
                    // Force persist a first launch date.
                    forcePersistFirstLaunchDate(Date(), persistor: persistor)

                    coordinator.promptIfUserQualifiesOn(viewController: UIViewController())
                    expect(fakePresenter.presentOnCalled) == false
                }

                it("does not call presenter if user doesn't qualify for minDaysAfterPrompted") {

                    let configuration = ReviewPromptingConfiguration(appName: "app", shouldTriage: true, isPromptingEnabled: true, minDaysAfterCrash: 0, minDaysAfterNegativeTriage: 0, minDaysAfterPrompted: 10, minDaysAfterFirstLaunch: 0, minSessions: 0)
                    let coordinator = ReviewPromptingCoordinator(configuration: configuration, customParameters: [], persistor: persistor, presenter: fakePresenter)
                    // Force persist a first launch date.
                    forcePersistFirstLaunchDate(Date(), persistor: persistor)
                    persistor.setLastPromptedDate(date: Date())

                    coordinator.promptIfUserQualifiesOn(viewController: UIViewController())
                    expect(fakePresenter.presentOnCalled) == false
                }

                it("does not call presenter if user has been prompted 3 times in the past year") {

                    let configuration = ReviewPromptingConfiguration(appName: "app", shouldTriage: true, isPromptingEnabled: true, minDaysAfterCrash: 0, minDaysAfterNegativeTriage: 0, minDaysAfterPrompted: 0, minDaysAfterFirstLaunch: 0, minSessions: 0)
                    let coordinator = ReviewPromptingCoordinator(configuration: configuration, customParameters: [], persistor: persistor, presenter: fakePresenter)
                    // Force persist a first launch date.
                    forcePersistFirstLaunchDate(Date(), persistor: persistor)
                    persistor.setLastPromptedDate(date: Date())
                    persistor.setLastPromptedDate(date: Date())
                    persistor.setLastPromptedDate(date: Date())

                    coordinator.promptIfUserQualifiesOn(viewController: UIViewController())
                    expect(fakePresenter.presentOnCalled) == false
                }

                it("does not call presenter if user doesn't qualify for minDaysAfterNegativeTriage") {

                    let configuration = ReviewPromptingConfiguration(appName: "app", shouldTriage: true, isPromptingEnabled: true, minDaysAfterCrash: 0, minDaysAfterNegativeTriage: 10, minDaysAfterPrompted: 0, minDaysAfterFirstLaunch: 0, minSessions: 0)
                    let coordinator = ReviewPromptingCoordinator(configuration: configuration, customParameters: [], persistor: persistor, presenter: fakePresenter)
                    // Force persist a first launch date.
                    forcePersistFirstLaunchDate(Date(), persistor: persistor)
                    persistor.set(date: Date(), forParameter: ReviewPromptingDefaultParameters.lastNegativeTriagedDate.rawValue)

                    coordinator.promptIfUserQualifiesOn(viewController: UIViewController())
                    expect(fakePresenter.presentOnCalled) == false
                }

                it("does not call presenter if user doesn't qualify for minDaysAfterCrash") {

                    let configuration = ReviewPromptingConfiguration(appName: "app", shouldTriage: true, isPromptingEnabled: true, minDaysAfterCrash: 10, minDaysAfterNegativeTriage: 10, minDaysAfterPrompted: 0, minDaysAfterFirstLaunch: 0, minSessions: 0)
                    let coordinator = ReviewPromptingCoordinator(configuration: configuration, customParameters: [], persistor: persistor, presenter: fakePresenter)
                    // Force persist a first launch date.
                    forcePersistFirstLaunchDate(Date(), persistor: persistor)
                    coordinator.appDidCrash()

                    coordinator.promptIfUserQualifiesOn(viewController: UIViewController())
                    expect(fakePresenter.presentOnCalled) == false
                }

                it("does not call presenter if user doesn't qualify for a custom parameter") {

                    let customParameter = ReviewPromptingCustomParameter(name: "tappedButton", threshold: 5)
                    let configuration = ReviewPromptingConfiguration(appName: "app", shouldTriage: true, isPromptingEnabled: true, minDaysAfterCrash: 0, minDaysAfterNegativeTriage: 10, minDaysAfterPrompted: 0, minDaysAfterFirstLaunch: 0, minSessions: 0)
                    let coordinator = ReviewPromptingCoordinator(configuration: configuration, customParameters: [customParameter], persistor: persistor, presenter: fakePresenter)
                    // Force persist a first launch date.
                    forcePersistFirstLaunchDate(Date(), persistor: persistor)

                    coordinator.promptIfUserQualifiesOn(viewController: UIViewController())
                    expect(fakePresenter.presentOnCalled) == false
                }

                it("prompts if user qualifies") {

                    let configuration = ReviewPromptingConfiguration(appName: "app", shouldTriage: true, isPromptingEnabled: true, minDaysAfterCrash: 0, minDaysAfterNegativeTriage: 0, minDaysAfterPrompted: 0, minDaysAfterFirstLaunch: 0, minSessions: 0)
                    let coordinator = ReviewPromptingCoordinator(configuration: configuration, customParameters: [], persistor: persistor, presenter: fakePresenter)
                    // Force persist a first launch date.
                    forcePersistFirstLaunchDate(Date(), persistor: persistor)

                    coordinator.promptIfUserQualifiesOn(viewController: UIViewController())
                    expect(fakePresenter.presentOnCalled) == true
                }

                it("does not prompt if user qualifies but prompting is disabled") {

                    let configuration = ReviewPromptingConfiguration(appName: "app", shouldTriage: true, isPromptingEnabled: false, minDaysAfterCrash: 0, minDaysAfterNegativeTriage: 0, minDaysAfterPrompted: 0, minDaysAfterFirstLaunch: 0, minSessions: 0)
                    let coordinator = ReviewPromptingCoordinator(configuration: configuration, customParameters: [], persistor: persistor, presenter: fakePresenter)
                    // Force persist a first launch date.
                    forcePersistFirstLaunchDate(Date(), persistor: persistor)

                    coordinator.promptIfUserQualifiesOn(viewController: UIViewController())
                    expect(fakePresenter.presentOnCalled) == false
                }
            }
        }
    }
}

func forcePersistFirstLaunchDate(_ date: Date, persistor: ReviewPromptingParameterPersistor) {
    // This is a workaround as normally this would be triggered in response to the app launch notification
    persistor.set(date: date, forParameter: ReviewPromptingDefaultParameters.firstLaunchDate.rawValue)
}

class FakeReviewPromptingPresenter: ReviewPromptingAlertPresenting {

    var presentOnCalled: Bool = false
    weak var delegate: ReviewPromptingAlertPresenterDelegate?

    func presentOn(viewController: UIViewController, withConfiguration configuration: ReviewPromptingConfiguration) {
        presentOnCalled = true
    }
}
