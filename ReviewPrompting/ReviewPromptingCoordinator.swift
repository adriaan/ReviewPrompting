//
//  ReviewPromptingCoordinator.swift
//  ReviewPrompting
//
//  Created by Adriaan on 19/7/18.
//  Copyright © 2018 Field Apps. All rights reserved.
//

import UIKit

public protocol ReviewPromptingCoordinatorDelegate: class {

    func reviewPromptingCoordinatorDidPresentTriage(coordinator: ReviewPromptingCoordinator)
    func reviewPromptingCoordinatorDidRespondPositivelyToTriage(coordinator: ReviewPromptingCoordinator)
    func reviewPromptingCoordinatorUserDidRespondNegativelyToTriage(coordinator: ReviewPromptingCoordinator)
    func reviewPromptingCoordinatorDidPresentReviewPrompt(coordinator: ReviewPromptingCoordinator)
}

public class ReviewPromptingCoordinator {

    private var customParameters: [ReviewPromptingCustomParameter]
    private var configuration: ReviewPromptingConfiguration
    private let persistor: ReviewPromptingParameterPersistor
    private let presenter: ReviewPromptingAlertPresenting

    public weak var delegate: ReviewPromptingCoordinatorDelegate?
    public var forceUserQualificationForTesting: Bool = false

    public init(
        configuration: ReviewPromptingConfiguration,
        customParameters: [ReviewPromptingCustomParameter] = [],
        persistor: ReviewPromptingParameterPersistor = ReviewPromptingParameterPersistor(),
        presenter: ReviewPromptingAlertPresenting = ReviewPromptingAlertPresenter()
        ) {
        self.configuration = configuration
        self.customParameters = customParameters
        self.persistor = persistor
        self.presenter = presenter
        self.presenter.delegate = self

        NotificationCenter.default.addObserver(self, selector: #selector(handleApplicationDidFinishLaunchingNotification), name: UIApplication.didFinishLaunchingNotification, object: nil)
    }

    public func updateWith(configuration: ReviewPromptingConfiguration, customParameters: [ReviewPromptingCustomParameter]) {
        self.configuration = configuration
        self.customParameters = customParameters
    }

    public func appDidCrash() {
        persistor.set(date: Date(), forParameter: ReviewPromptingDefaultParameters.lastCrashDate.rawValue)
    }

    public func promptIfUserQualifiesOn(viewController: UIViewController) {
        guard configuration.isPromptingEnabled, userQualifies() else { return }
        presenter.presentOn(viewController: viewController, withConfiguration: configuration)
    }

    public func incrementCustomParameterWith(name: String) {
        guard customParameterIsRegisteredFor(name: name) else { return }
        persistor.increment(parameter: name)
    }

    public func setValue(_ value: Int, forCustomParameterWithName name: String) {
        guard customParameterIsRegisteredFor(name: name) else { return }
        persistor.set(value: value, forParameter: name)
    }

    private func customParameterIsRegisteredFor(name: String) -> Bool {
        let parameter = customParameters.first(where: { $0.name == name })
        return parameter != nil
    }

    private func userQualifies() -> Bool {
        guard #available(iOS 10.3, *) else { return false }
        guard forceUserQualificationForTesting == false else { return true }

        guard userQualifiesForDaysAfterFirstLaunch() else { return false }
        guard userQualifiesForNumSessions() else { return false }
        guard userQualifiesForLastCrashDate() else { return false }
        guard userQualifiesForNumberOfPromptsPerYear() else { return false }
        guard userQualifiesForDaysSinceLastPrompted() else { return false }
        guard userQualifiesForDaysSinceNegativeTriage() else { return false }
        guard userQualifiesForCustomParameters() else { return false }
        return true
    }

    private func userQualifiesForDaysAfterFirstLaunch() -> Bool {
        guard let firstLaunchDate = persistor.dateFor(parameter: ReviewPromptingDefaultParameters.firstLaunchDate.rawValue), firstLaunchDate.timeIntervalSinceNow < TimeInterval(-24 * 3600 * configuration.minDaysAfterFirstLaunch) else { return false }
        return true
    }

    private func userQualifiesForNumSessions() -> Bool {
        guard persistor.valueFor(parameter: ReviewPromptingDefaultParameters.numSessions.rawValue) >= configuration.minSessions else { return false }
        return true
    }

    private func userQualifiesForLastCrashDate() -> Bool {
        if let lastCrashDate = persistor.dateFor(parameter: ReviewPromptingDefaultParameters.lastCrashDate.rawValue), lastCrashDate.timeIntervalSinceNow > TimeInterval(-24 * 3600 * configuration.minDaysAfterCrash) { return false }
        return true
    }

    private func userQualifiesForNumberOfPromptsPerYear() -> Bool {
        let lastPromptedDates = persistor.promptedDates()
        if lastPromptedDates.count == 3, let firstPromptedDate = lastPromptedDates.first, firstPromptedDate.timeIntervalSinceNow > TimeInterval(-365 * 24 * 3600) { return false }
        return true
    }

    private func userQualifiesForDaysSinceLastPrompted() -> Bool {
        let lastPromptedDates = persistor.promptedDates()
        if let mostRecentPromptedDate = lastPromptedDates.last, mostRecentPromptedDate.timeIntervalSinceNow > TimeInterval( -24 * 3600 * configuration.minDaysAfterPrompted) { return false }
        return true
    }

    private func userQualifiesForDaysSinceNegativeTriage() -> Bool {
        if let lastNegativeTriageDate = persistor.dateFor(parameter: ReviewPromptingDefaultParameters.lastNegativeTriagedDate.rawValue), lastNegativeTriageDate.timeIntervalSinceNow > TimeInterval( -24 * 3600 * configuration.minDaysAfterNegativeTriage) { return false }
        return true
    }

    private func userQualifiesForCustomParameters() -> Bool {
        return customParameters.reduce(true) { (intermediate, customParameter) -> Bool in
            guard intermediate == true else { return false }
            let currentValue = persistor.valueFor(parameter: customParameter.name)
            return currentValue >= customParameter.threshold
        }
    }

    @objc private func handleApplicationDidFinishLaunchingNotification() {
        persistor.increment(parameter: ReviewPromptingDefaultParameters.numSessions.rawValue)
        guard persistor.dateFor(parameter: ReviewPromptingDefaultParameters.firstLaunchDate.rawValue) == nil else { return }
        persistor.set(date: Date(), forParameter: ReviewPromptingDefaultParameters.firstLaunchDate.rawValue)
    }
}

extension ReviewPromptingCoordinator: ReviewPromptingAlertPresenterDelegate {

    public func reviewPromptingAlertPresenterDidPresentTriage(presenter: ReviewPromptingAlertPresenter) {
        delegate?.reviewPromptingCoordinatorDidPresentTriage(coordinator: self)
    }

    public func reviewPromptingAlertPresenterUserDidRespondPositivelyToTriage(presenter: ReviewPromptingAlertPresenter) {
        delegate?.reviewPromptingCoordinatorDidRespondPositivelyToTriage(coordinator: self)
    }

    public func reviewPromptingAlertPresenterUserDidRespondNegativelyToTriage(presenter: ReviewPromptingAlertPresenter) {
        persistor.set(date: Date(), forParameter: ReviewPromptingDefaultParameters.lastNegativeTriagedDate.rawValue)
        delegate?.reviewPromptingCoordinatorUserDidRespondNegativelyToTriage(coordinator: self)
    }

    public func reviewPromptingAlertPresenterDidPresentReviewPrompt(presenter: ReviewPromptingAlertPresenter) {
        persistor.setLastPromptedDate(date: Date())
        delegate?.reviewPromptingCoordinatorDidPresentReviewPrompt(coordinator: self)
    }
}
