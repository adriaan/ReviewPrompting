//
//  ReviewPromptingAlertPresenter.swift
//  ReviewPrompting
//
//  Created by Adriaan on 19/7/18.
//  Copyright © 2018 Field Apps. All rights reserved.
//

import StoreKit

protocol ReviewPromptingAlertPresenterDelegate: class {

    func reviewPromptingAlertPresenterDidPresentTriage(presenter: ReviewPromptingAlertPresenter)
    func reviewPromptingAlertPresenterUserDidRespondPositivelyToTriage(presenter: ReviewPromptingAlertPresenter)
    func reviewPromptingAlertPresenterUserDidRespondNegativelyToTriage(presenter: ReviewPromptingAlertPresenter)
    func reviewPromptingAlertPresenterDidPresentReviewPrompt(presenter: ReviewPromptingAlertPresenter)
}

protocol ReviewPromptingAlertPresenting: class {

    var delegate: ReviewPromptingAlertPresenterDelegate? { get set }
    func presentOn(viewController: UIViewController, withConfiguration configuration: ReviewPromptingConfiguration)
}

class ReviewPromptingAlertPresenter: ReviewPromptingAlertPresenting {

    weak var delegate: ReviewPromptingAlertPresenterDelegate?

    func presentOn(viewController: UIViewController, withConfiguration configuration: ReviewPromptingConfiguration) {
        guard #available(iOS 10.3, *) else { return }
        if configuration.shouldTriage {
            presentTriageOn(viewController: viewController, withConfiguration: configuration)
        } else {
            presentReviewPrompt()
        }
    }

    private func presentTriageOn(viewController: UIViewController, withConfiguration configuration: ReviewPromptingConfiguration) {
        guard let alert = makeTriageAlertWith(configuration: configuration) else { return }
        viewController.present(alert, animated: true) {
            self.delegate?.reviewPromptingAlertPresenterDidPresentTriage(presenter: self)
        }
    }

    private func makeTriageAlertWith(configuration: ReviewPromptingConfiguration) -> UIAlertController? {
        // SKStoreReviewController is only available in iOS 10.3+
        // This method should never be called for users below iOS 10.3 as presentOn(viewController: UIViewController) excludes them.
        // This guard and the optional return type is purely defensive.
        guard #available(iOS 10.3, *) else { return .none }

        let alertController = UIAlertController(title: "Are you enjoying \(configuration.appName)?", message: .none, preferredStyle: .alert)

        let positiveAction = UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.reviewPromptingAlertPresenterUserDidRespondPositivelyToTriage(presenter: strongSelf)
            strongSelf.presentReviewPrompt()
        }
        let negativeAction = UIAlertAction(title: "No", style: .default) { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.reviewPromptingAlertPresenterUserDidRespondNegativelyToTriage(presenter: strongSelf)
        }
        alertController.addAction(positiveAction)
        alertController.addAction(negativeAction)

        return alertController
    }

    private func presentReviewPrompt() {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
            delegate?.reviewPromptingAlertPresenterDidPresentReviewPrompt(presenter: self)
        } else {
            // Fallback on earlier versions
        }
    }
}
