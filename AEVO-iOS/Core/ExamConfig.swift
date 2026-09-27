import Foundation

public enum QuestionType: String, Codable, Sendable { case singleChoice, multipleChoice }
public struct ExamConfig: Codable, Equatable, Sendable {
    public enum Selection: String, Codable, Sendable { case random, weightedRandom }
    public enum Navigation: String, Codable, Sendable { case free, forwardOnly }
    public enum Timing: String, Codable, Sendable { case continuous, activeOnly }
    public enum Scoring: String, Codable, Sendable { case allOrNothing, partialCredit }
    public enum Results: String, Codable, Sendable { case detailed, summary }
    public struct Weight: Codable, Equatable, Sendable { public let categoryID: Int; public let weight: Double }
    public let version: Int; public let id: String; public let title: String
    public let questionCount: Int; public let durationSeconds: Int; public let passPercentage: Double
    public let selection: Selection; public let categoryWeights: [Weight]; public let uniqueFamilies: Bool
    public let navigation: Navigation; public let allowsAnswerChanges: Bool
    public let timing: Timing; public let scoring: Scoring; public let results: Results
    public func quotas() -> [Int: Int] {
        guard selection == .weightedRandom else { return [:] }
        let sum = categoryWeights.reduce(0) { $0 + $1.weight }
        guard sum > 0 else { return [:] }
        let values = categoryWeights.map { ($0.categoryID, Double(questionCount) * $0.weight / sum) }
        var quotas = Dictionary(uniqueKeysWithValues: values.map { ($0.0, Int(floor($0.1))) })
        let remainder = questionCount - quotas.values.reduce(0, +)
        let order = values.sorted { a,b in
            let x = a.1 - floor(a.1), y = b.1 - floor(b.1)
            return x == y ? a.0 < b.0 : x > y
        }
        for item in order.prefix(max(0,remainder)) { quotas[item.0, default: 0] += 1 }
        return quotas
    }
    public func validate(categories: Set<Int>, questions: [Question]) throws {
        guard version == 1, !id.isEmpty, !title.isEmpty, (1...10_000).contains(questionCount),
              (1...604_800).contains(durationSeconds), passPercentage.isFinite, (0...100).contains(passPercentage),
              Set(categoryWeights.map(\.categoryID)).count == categoryWeights.count,
              categoryWeights.allSatisfy({ categories.contains($0.categoryID) && $0.weight.isFinite && $0.weight > 0 }),
              selection != .weightedRandom || !categoryWeights.isEmpty,
              selection != .random || categoryWeights.isEmpty else { throw LearningError.invalid("exam_config: ungültige Dauer, Anzahl, Gewichtung oder Bestehensgrenze.") }
        // A family is scoped to exactly one category; this makes quotas deterministic.
        if uniqueFamilies {
            let groups = Dictionary(grouping: questions, by: \.family)
            guard groups.values.allSatisfy({ Set($0.map(\.field)).count == 1 }) else { throw LearningError.invalid("exam_config: Eine Aufgabenfamilie liegt in mehreren Themenbereichen.") }
        }
        func available(_ qs: [Question]) -> Int { uniqueFamilies ? Set(qs.map(\.family)).count : qs.count }
        if selection == .random {
            guard available(questions) >= questionCount else { throw LearningError.invalid("exam_config: Zu wenige Aufgaben oder unabhängige Familien.") }
        } else {
            for (field,count) in quotas() where available(questions.filter { $0.field == field }) < count {
                throw LearningError.invalid("exam_config: Kategorie \(field) benötigt \(count) unabhängige Aufgaben.")
            }
        }
    }
    public func select(from catalog: Catalog) throws -> [Question] {
        try validate(categories: Set(catalog.questions.map(\.field)), questions: catalog.questions)
        func pool(_ questions: [Question]) -> [Question] {
            var families: Set<String> = []
            return questions.shuffled().filter { !uniqueFamilies || families.insert($0.family).inserted }
        }
        if selection == .random { return Array(pool(catalog.questions).prefix(questionCount)) }
        return quotas().sorted { $0.key < $1.key }.flatMap { field,count in
            Array(pool(catalog.questions.filter { $0.field == field }).prefix(count))
        }.shuffled()
    }
    public func score(question: Question, selected: Set<String>) -> Double {
        guard !selected.isEmpty, selected.isSubset(of: Set(question.options.map(\.id))) else { return 0 }
        if scoring == .allOrNothing { return question.isCorrect(selected) ? 1 : 0 }
        return max(0, Double(selected.intersection(question.correctIDs).count - selected.subtracting(question.correctIDs).count) / Double(question.correctIDs.count))
    }
}

public extension ExamSession {
    var passed: Bool { points >= (rules?.passPercentage ?? 100) }
    var canShowDetails: Bool { rules?.results != .summary }
    func canNavigate(to target: Int) -> Bool {
        guard submittedAt == nil, questions.indices.contains(target) else { return false }
        return rules?.navigation != .forwardOnly || target == index + 1 || target == index
    }
    mutating func navigate(to target: Int) {
        guard canNavigate(to: target) else { return }
        if target != index && rules?.allowsAnswerChanges == false {
            var locked = lockedQuestionIDs ?? []; locked.insert(questions[index].id); lockedQuestionIDs = locked
        }
        index = target; viewed.insert(questions[target].id)
    }
    mutating func select(optionID: String) {
        guard submittedAt == nil, questions.indices.contains(index) else { return }
        let q = questions[index]
        guard lockedQuestionIDs?.contains(q.id) != true, q.options.contains(where: { $0.id == optionID }) else { return }
        var chosen = selections[q.id] ?? []
        if q.multipleChoice { if chosen.contains(optionID) { chosen.remove(optionID) } else { chosen.insert(optionID) } }
        else { chosen = [optionID] }
        selections[q.id] = chosen
    }
    func remaining(now: Date) -> TimeInterval {
        if rules?.timing == .activeOnly { return max(0, (remainingActiveSeconds ?? 0) - (clockRunning == true ? max(0, now.timeIntervalSince(lastObservedAt)) : 0)) }
        return max(0, deadline.timeIntervalSince(now))
    }
    mutating func setActive(_ active: Bool, now: Date, uptime: TimeInterval) {
        if clockRunning == true { observe(now: now, uptime: uptime) }
        clockRunning = active; lastObservedAt = now; lastObservedUptime = uptime
    }
}
