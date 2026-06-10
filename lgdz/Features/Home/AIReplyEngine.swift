import Foundation

/// Local dog-walking themed reply templates (架构需求.md §6: AI 仅 UI, 不接模型).
enum AIReplyEngine {
    private static let replies = [
        "The banks of the Seine in Paris~",
        "Early morning is the best time for a walk — cooler and quieter.",
        "Try a 30-minute loop around the nearest park, your pup will love it!",
        "Remember to bring water and a few treats for training along the way.",
        "Rainy day? A short sniff-walk plus indoor play keeps them happy.",
        "Golden retrievers love long walks — aim for 60 minutes split in two.",
        "Socializing with other dogs at the park is great for their mood.",
    ]
    private static var index = 0

    static func reply(to message: String) -> String {
        defer { index = (index + 1) % replies.count }
        return replies[index]
    }
}
