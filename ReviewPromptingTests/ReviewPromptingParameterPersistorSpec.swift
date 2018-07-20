//
//  ReviewPromptingPersistorSpec.swift
//  ReviewPromptingTests
//
//  Created by Adriaan on 20/7/18.
//  Copyright © 2018 Field Apps. All rights reserved.
//

import Quick
import Nimble
@testable import ReviewPrompting

class ReviewPromptingParemeterPersistorSpec: QuickSpec {

    override func spec() {

        describe("ReviewPromptingParameterPersistor") {

            var persistor: ReviewPromptingParameterPersistor!
            beforeEach {
                persistor = ReviewPromptingParameterPersistor()
            }

            afterEach {
                UserDefaults.standard.dictionaryRepresentation().forEach({ (key, _) in
                    UserDefaults.standard.removeObject(forKey: key)
                })
            }

            describe("increment parameter") {

                it("increments and persists the parameter") {

                    expect(persistor.valueFor(parameter: "parameter")) == 0

                    persistor.increment(parameter: "parameter")
                    expect(persistor.valueFor(parameter: "parameter")) == 1
                }
            }

            describe("set value for parameter") {

                it("sets and persists the parameter value") {

                    expect(persistor.valueFor(parameter: "parameter")) == 0

                    persistor.set(value: 10, forParameter: "parameter")
                    expect(persistor.valueFor(parameter: "parameter")) == 10
                }
            }

            describe("set date for parameter") {

                it("sets and persists the parameter date") {

                    let date = Date()
                    expect(persistor.dateFor(parameter: "dateParameter")).to(beNil())

                    persistor.set(date: date, forParameter: "dateParameter")
                    expect(persistor.dateFor(parameter: "dateParameter")) == date
                }
            }

            describe("set last prompted date") {

                context("when no dates persisted yet") {

                    it("persists the date") {

                        let initialPromptedDates = persistor.promptedDates()
                        expect(initialPromptedDates.isEmpty) == true

                        let date = Date()
                        persistor.setLastPromptedDate(date: date)

                        let promptedDates = persistor.promptedDates()
                        expect(promptedDates.count) == 1
                        expect(promptedDates.last!) == date
                    }
                }

                context("when less than 3 dates are persisted already") {

                    it("appends the date to the existing dates and persists") {
                        let initialDate = Date().addingTimeInterval(-10)
                        persistor.setLastPromptedDate(date: initialDate)
                        let initialPromptedDates = persistor.promptedDates()
                        expect(initialPromptedDates.count) == 1

                        let date = Date()
                        persistor.setLastPromptedDate(date: date)

                        let promptedDates = persistor.promptedDates()
                        expect(promptedDates.count) == 2
                        expect(promptedDates.last!) == date
                    }
                }

                context("when 3 dates are persisted already") {

                    it("appends the date to the existing dates, removes the first date and persists") {

                        let initialDateOne = Date().addingTimeInterval(-30)
                        let initialDateTwo = Date().addingTimeInterval(-20)
                        let initialDateThree = Date().addingTimeInterval(-10)

                        persistor.setLastPromptedDate(date: initialDateOne)
                        persistor.setLastPromptedDate(date: initialDateTwo)
                        persistor.setLastPromptedDate(date: initialDateThree)

                        let initialPromptedDates = persistor.promptedDates()
                        expect(initialPromptedDates.count) == 3

                        let date = Date()
                        persistor.setLastPromptedDate(date: date)

                        let promptedDates = persistor.promptedDates()
                        expect(promptedDates.count) == 3
                        expect(promptedDates.last!) == date
                        expect(promptedDates.first!) == initialDateTwo
                    }
                }
            }
        }
    }
}
