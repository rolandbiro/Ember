import Foundation

struct AssessmentQuestion: Identifiable {
    let id: Int
    let text: String
    let dimension: AssessmentDimension
}

enum AssessmentDimension {
    case exhaustion
    case cynicism
    case efficacy
}

enum BurnoutLevel {
    case mild, moderate, severe

    var title: String {
        switch self {
        case .mild: return "Mild Signs"
        case .moderate: return "Moderate Signs"
        case .severe: return "Strong Signs"
        }
    }

    var message: String {
        switch self {
        case .mild: return "You're on the right track - prevention mode"
        case .moderate: return "Pay attention to yourself - time to slow down"
        case .severe: return "You need support - we'll go step by step"
        }
    }
}

struct Assessment {
    static let questions: [AssessmentQuestion] = [
        AssessmentQuestion(id: 1, text: "I feel emotionally drained from my work", dimension: .exhaustion),
        AssessmentQuestion(id: 2, text: "I feel used up at the end of the workday", dimension: .exhaustion),
        AssessmentQuestion(id: 3, text: "I feel tired when I get up to face another day", dimension: .exhaustion),
        AssessmentQuestion(id: 4, text: "I have become less interested in my work", dimension: .cynicism),
        AssessmentQuestion(id: 5, text: "I have become less enthusiastic about my work", dimension: .cynicism),
        AssessmentQuestion(id: 6, text: "I doubt the significance of my work", dimension: .cynicism),
        AssessmentQuestion(id: 7, text: "I can effectively solve problems that arise", dimension: .efficacy),
        AssessmentQuestion(id: 8, text: "I feel I'm making an effective contribution", dimension: .efficacy),
        AssessmentQuestion(id: 9, text: "I feel good about accomplishing things", dimension: .efficacy)
    ]

    static let answerOptions = [
        "Never",
        "A few times a year",
        "Once a month",
        "A few times a month",
        "Once a week",
        "A few times a week",
        "Every day"
    ]

    static func calculatePace(answers: [Int: Int]) -> Pace {
        var exhaustionScore = 0
        var cynicismScore = 0
        var efficacyScore = 0

        for (questionId, answerIndex) in answers {
            guard let question = questions.first(where: { $0.id == questionId }) else { continue }

            switch question.dimension {
            case .exhaustion:
                exhaustionScore += answerIndex
            case .cynicism:
                cynicismScore += answerIndex
            case .efficacy:
                efficacyScore += (6 - answerIndex)
            }
        }

        let totalScore = exhaustionScore + cynicismScore + efficacyScore

        if totalScore >= 36 {
            return .gentle
        } else if totalScore >= 18 {
            return .steady
        } else {
            return .active
        }
    }

    static func calculateBurnoutLevel(answers: [Int: Int]) -> BurnoutLevel {
        var totalScore = 0
        for (questionId, answerIndex) in answers {
            guard let question = questions.first(where: { $0.id == questionId }) else { continue }
            if question.dimension == .efficacy {
                totalScore += (6 - answerIndex)
            } else {
                totalScore += answerIndex
            }
        }

        if totalScore >= 36 { return .severe }
        else if totalScore >= 18 { return .moderate }
        else { return .mild }
    }

    static func personalizedMessage(situation: Situation?, goal: Goal?) -> String {
        guard let situation = situation, let goal = goal else {
            return "We'll take it step by step together."
        }

        let sitText: String
        switch situation {
        case .overwhelmed: sitText = "work is overwhelming you"
        case .exhausted: sitText = "you feel emotionally exhausted"
        case .lostMotivation: sitText = "you've lost motivation"
        case .alwaysTired: sitText = "you're always tired"
        case .prevention: sitText = "you want to prevent burnout"
        }

        let goalText: String
        switch goal {
        case .recoverEnergy: goalText = "recover your energy"
        case .findBalance: goalText = "find balance"
        case .feelMyself: goalText = "feel like yourself again"
        case .healthyHabits: goalText = "build healthier habits"
        }

        return "You said \(sitText), and you want to \(goalText). We'll take small steps together."
    }
}
