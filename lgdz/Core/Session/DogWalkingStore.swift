import Foundation

extension Notification.Name {
    static let walkDiaryDidChange = Notification.Name("dog.walkDiaryDidChange")
    static let dogProfileDidChange = Notification.Name("dog.profileDidChange")
}

/// Dog size used for buddy matching.
enum DogSize: String, Codable, CaseIterable {
    case small = "Small"
    case medium = "Medium"
    case large = "Large"
}

/// A dog profile attached to a walker (breed / size / personality tags).
struct DogProfile: Codable, Equatable {
    var dogName: String
    var breed: String
    var size: DogSize
    var personality: [String]

    static let empty = DogProfile(dogName: "", breed: "", size: .medium, personality: [])
}

/// One walk check-in entry in the user's diary.
struct WalkCheckIn: Codable, Identifiable, Equatable {
    let id: String
    let date: Date
    var note: String
    var durationMinutes: Int
}

struct DogMatchResult: Equatable {
    let userId: String
    let userName: String
    let avatar: String
    let dog: DogProfile
    let score: Int
    let matchPercent: Int
    let matchedTraits: [String]
}

/// Local walk diary + dog profile + buddy matching (架构需求.md §6: 轻量拟真本地).
enum DogWalkingStore {

    static let breeds: [String] = [
        "Golden Retriever", "Husky", "Corgi", "Shiba Inu", "Labrador",
        "Mixed", "Border Collie", "Australian Shepherd", "Terrier Mix", "Poodle",
    ]

    static let personalities: [String] = [
        "Friendly", "Energetic", "Calm", "Playful",
        "Shy", "Social", "Independent", "Curious",
    ]

    private static let profileKey = "dog.profile"
    private static let diaryKey = "walk.diary"

    /// Built-in demo users each own one dog with distinct tags.
    static let demoDogs: [String: DogProfile] = [
        "u_emma": DogProfile(dogName: "Biscuit", breed: "Mixed", size: .medium,
                             personality: ["Friendly", "Social"]),
        "u_james": DogProfile(dogName: "Dash", breed: "Mixed", size: .large,
                              personality: ["Energetic", "Independent"]),
        "u_sophie": DogProfile(dogName: "Coco", breed: "Mixed", size: .medium,
                              personality: ["Friendly", "Playful"]),
        "u_max": DogProfile(dogName: "Peanut", breed: "Mixed", size: .small,
                           personality: ["Energetic", "Social"]),
        "u_lily": DogProfile(dogName: "Mochi", breed: "Terrier Mix", size: .small,
                            personality: ["Calm", "Shy"]),
        "u_william": DogProfile(dogName: "Kenji", breed: "Shiba Inu", size: .medium,
                                personality: ["Independent", "Curious"]),
        "u_olivia": DogProfile(dogName: "Scout", breed: "Mixed", size: .medium,
                               personality: ["Friendly", "Calm"]),
        "u_leo": DogProfile(dogName: "Shadow", breed: "Border Collie", size: .medium,
                            personality: ["Energetic", "Curious"]),
        "u_grace": DogProfile(dogName: "Buddy", breed: "Mixed", size: .small,
                              personality: ["Playful", "Social"]),
        "u_noah": DogProfile(dogName: "Luna", breed: "Mixed", size: .small,
                             personality: ["Energetic", "Friendly"]),
    ]

    /// Pre-seeded for the built-in review account (Harper / lgdz@qq.com).
    static let testAccountDefaultDog = DogProfile(
        dogName: "Maple",
        breed: "Golden Retriever",
        size: .large,
        personality: ["Friendly", "Social"])

    static func dog(forUserId userId: String) -> DogProfile? {
        demoDogs[userId]
    }

    static func dog(for user: DemoContent.FeedUser) -> DogProfile? {
        if user.id == DemoContent.currentUserId {
            return currentUserDogProfile()
        }
        return demoDogs[user.id]
    }

    // MARK: - Current user dog profile

    static func currentUserDogProfile() -> DogProfile? {
        guard let data = AppSession.shared.storage?.data(profileKey),
              let profile = try? JSONDecoder().decode(DogProfile.self, from: data),
              !profile.breed.isEmpty else { return nil }
        return profile
    }

    static func saveCurrentUserDogProfile(_ profile: DogProfile) {
        guard let data = try? JSONEncoder().encode(profile) else { return }
        AppSession.shared.storage?.set(data, for: profileKey)
        NotificationCenter.default.post(name: .dogProfileDidChange, object: nil)
    }

    /// Seeds Harper's default dog when the test account has no saved profile yet.
    static func seedDefaultDogProfileForCurrentAccountIfNeeded() {
        guard AppSession.shared.isTestAccount,
              AppSession.shared.storage != nil,
              currentUserDogProfile() == nil else { return }
        saveCurrentUserDogProfile(testAccountDefaultDog)
    }

    /// One-line summary for profile headers.
    static func profileSummary(for dog: DogProfile) -> String {
        "\(dog.dogName) · \(dog.breed) · \(dog.size.rawValue)"
    }

    // MARK: - Walk diary

    static func walkDiaryEntries() -> [WalkCheckIn] {
        guard let data = AppSession.shared.storage?.data(diaryKey),
              let entries = try? JSONDecoder().decode([WalkCheckIn].self, from: data) else { return [] }
        return entries.sorted { $0.date > $1.date }
    }

    static func addCheckIn(note: String, durationMinutes: Int) {
        var entries = walkDiaryEntries()
        let entry = WalkCheckIn(
            id: UUID().uuidString,
            date: Date(),
            note: note.trimmingCharacters(in: .whitespacesAndNewlines),
            durationMinutes: durationMinutes)
        entries.insert(entry, at: 0)
        persistDiary(entries)
    }

    static func deleteCheckIn(id: String) {
        let entries = walkDiaryEntries().filter { $0.id != id }
        persistDiary(entries)
    }

    static func hasCheckedInToday() -> Bool {
        let cal = Calendar.current
        return walkDiaryEntries().contains { cal.isDateInToday($0.date) }
    }

    static func currentStreak() -> Int {
        let cal = Calendar.current
        let days = Set(walkDiaryEntries().map { cal.startOfDay(for: $0.date) })
        guard !days.isEmpty else { return 0 }
        var streak = 0
        var cursor = cal.startOfDay(for: Date())
        while days.contains(cursor) {
            streak += 1
            guard let prev = cal.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = prev
        }
        return streak
    }

    private static func persistDiary(_ entries: [WalkCheckIn]) {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        AppSession.shared.storage?.set(data, for: diaryKey)
        NotificationCenter.default.post(name: .walkDiaryDidChange, object: nil)
    }

    // MARK: - Matching

    /// Returns demo walkers sorted by tag similarity (breed 40, size 30, personality 10 each).
    static func matchBuddies(query: DogProfile, limit: Int = 20) -> [DogMatchResult] {
        guard !query.breed.isEmpty else { return [] }

        let blocked = AppSession.shared.blockedNames
        var results: [DogMatchResult] = []

        for user in DemoContent.feedUsers {
            guard user.id != DemoContent.currentUserId,
                  !blocked.contains(user.name),
                  let dog = demoDogs[user.id] else { continue }

            let scored = score(query: query, candidate: dog)
            guard scored.score >= 20 else { continue }

            results.append(DogMatchResult(
                userId: user.id,
                userName: user.name,
                avatar: user.avatar,
                dog: dog,
                score: scored.score,
                matchPercent: scored.percent,
                matchedTraits: scored.traits))
        }

        return results
            .sorted { lhs, rhs in
                if lhs.score != rhs.score { return lhs.score > rhs.score }
                return lhs.userName < rhs.userName
            }
            .prefix(limit)
            .map { $0 }
    }

    private static func score(query: DogProfile, candidate: DogProfile) -> (score: Int, percent: Int, traits: [String]) {
        var score = 0
        var traits: [String] = []

        if query.breed.caseInsensitiveCompare(candidate.breed) == .orderedSame {
            score += 40
            traits.append(candidate.breed)
        }
        if query.size == candidate.size {
            score += 30
            traits.append(candidate.size.rawValue)
        }
        let overlap = Set(query.personality).intersection(candidate.personality)
        for tag in overlap.sorted() {
            score += 10
            traits.append(tag)
        }

        let maxScore = 40 + 30 + min(query.personality.count, 3) * 10
        let percent = maxScore > 0 ? min(100, Int((Double(score) / Double(maxScore)) * 100)) : 0
        return (score, percent, traits)
    }

    static func formattedDate(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        fmt.timeStyle = .short
        return fmt.string(from: date)
    }

    static func relativeDay(_ date: Date) -> String {
        let cal = Calendar.current
        if cal.isDateInToday(date) { return "Today" }
        if cal.isDateInYesterday(date) { return "Yesterday" }
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM d"
        return fmt.string(from: date)
    }
}
