import Foundation
import UIKit

extension Notification.Name {
    /// Posted when a feed user's follow state changes. `userInfo`: `FollowUserInfoKey.userId`, `FollowUserInfoKey.following`.
    static let followStateDidChange = Notification.Name("demo.followStateDidChange")
    /// Posted when a post's like state changes. `userInfo`: `LikePostInfoKey.postId`, `LikePostInfoKey.liked`.
    static let likeStateDidChange = Notification.Name("demo.likeStateDidChange")
    /// Posted when the signed-in user publishes a new feed post.
    static let userPostDidPublish = Notification.Name("demo.userPostDidPublish")
    /// Posted when the signed-in user deletes one of their feed posts. `object`: post id.
    static let userPostDidDelete = Notification.Name("demo.userPostDidDelete")
    /// Posted when AI chat messages are added or updated for the current account.
    static let aiChatDidChange = Notification.Name("demo.aiChatDidChange")
    /// Posted when a user is blocked or unblocked. `object`: user display name.
    static let blockStateDidChange = Notification.Name("demo.blockStateDidChange")
    /// Posted when a live room follow state changes. `object`: live room id.
    static let liveFollowStateDidChange = Notification.Name("demo.liveFollowStateDidChange")
    /// Posted when a conversation is marked read (unread count cleared).
    static let chatUnreadDidChange = Notification.Name("demo.chatUnreadDidChange")
}

enum FollowUserInfoKey {
    static let userId = "userId"
    static let following = "following"
}

enum LikePostInfoKey {
    static let postId = "postId"
    static let liked = "liked"
}

/// Lightweight local demo data (架构需求.md §6: 轻量拟真本地, no remote API).
enum DemoContent {

    // MARK: - Feed users & posts

    struct FeedUser {
        let id: String
        let avatar: String
        let name: String
        let bio: String
        let coverImage: String
        let friends: Int
        let followed: Int
        let fans: Int
    }

    struct Activity: Codable {
        let id: String
        let userId: String
        let avatar: String
        let name: String
        let time: String
        let text: String
        let image: String
        var following: Bool
        let likes: String
        let comments: String
        let shares: String
        var liked: Bool
    }

    struct PostComment {
        let userId: String
        let avatar: String
        let name: String
        let text: String
    }

    static let feedUsers: [FeedUser] = [
        FeedUser(id: "u_emma", avatar: "avatar_a", name: "Emma", bio: "Golden Retriever mom · sunrise walks",
                 coverImage: "avatar_a", friends: 23, followed: 128, fans: 56),
        FeedUser(id: "u_james", avatar: "avatar_b", name: "James", bio: "Husky trainer · early riser",
                 coverImage: "avatar_b", friends: 18, followed: 94, fans: 41),
        FeedUser(id: "u_sophie", avatar: "avatar_poster", name: "Sophie", bio: "Love long walks 🐕",
                 coverImage: "avatar_poster", friends: 31, followed: 210, fans: 88),
        FeedUser(id: "u_max", avatar: "avatar_c", name: "Max", bio: "Corgi dad · short legs, big heart",
                 coverImage: "avatar_c", friends: 15, followed: 76, fans: 33),
        FeedUser(id: "u_lily", avatar: "avatar_user", name: "Lily", bio: "Weekend park walker",
                 coverImage: "avatar_user", friends: 27, followed: 142, fans: 61),
        FeedUser(id: "u_william", avatar: "feed_post_01", name: "William", bio: "Shiba Inu enthusiast",
                 coverImage: "feed_post_01", friends: 12, followed: 58, fans: 29),
        FeedUser(id: "u_olivia", avatar: "feed_post_02", name: "Olivia", bio: "Rescue dog advocate",
                 coverImage: "feed_post_02", friends: 35, followed: 186, fans: 72),
        FeedUser(id: "u_leo", avatar: "feed_post_03", name: "Leo", bio: "Night owl dog walker",
                 coverImage: "feed_post_03", friends: 9, followed: 44, fans: 18),
        FeedUser(id: "u_grace", avatar: "feed_post_04", name: "Grace", bio: "Puppy socializer",
                 coverImage: "feed_post_04", friends: 41, followed: 203, fans: 95),
        FeedUser(id: "u_noah", avatar: "feed_post_05", name: "Noah", bio: "Trail hikes with Luna",
                 coverImage: "feed_post_05", friends: 20, followed: 112, fans: 47),
    ]

    static let feedPosts: [Activity] = [
        // Emma — 2 posts
        Activity(id: "p_emma_1", userId: "u_emma", avatar: "avatar_a", name: "Emma",
                 time: "5 hours ago",
                 text: "Morning sunshine at Riverside Park — Biscuit made five new friends!",
                 image: "content_dog1", following: false, likes: "842", comments: "5", shares: "126", liked: false),
        Activity(id: "p_emma_2", userId: "u_emma", avatar: "avatar_a", name: "Emma",
                 time: "1 day ago",
                 text: "New rope toy test: 10/10 durability, 0/10 for my furniture.",
                 image: "feed_post_06", following: false, likes: "516", comments: "3", shares: "89", liked: true),
        // James — 1 post
        Activity(id: "p_james_1", userId: "u_james", avatar: "avatar_b", name: "James",
                 time: "4 hours ago",
                 text: "Dash finally nailed 'stay' on our hill run. Proud dad moment.",
                 image: "content_dog2", following: true, likes: "1.1k", comments: "7", shares: "204", liked: true),
        // Sophie — 2 posts
        Activity(id: "p_sophie_1", userId: "u_sophie", avatar: "avatar_poster", name: "Sophie",
                 time: "6 hours ago",
                 text: "Beach sunset walk — sand paws and happy tail wags everywhere.",
                 image: "feed_post_07", following: true, likes: "2.3k", comments: "6", shares: "412", liked: true),
        Activity(id: "p_sophie_2", userId: "u_sophie", avatar: "avatar_poster", name: "Sophie",
                 time: "2 days ago",
                 text: "Sunday group walk! Who's joining us next weekend?",
                 image: "content_post1", following: true, likes: "978", comments: "4", shares: "167", liked: false),
        // Max — 1 post
        Activity(id: "p_max_1", userId: "u_max", avatar: "avatar_c", name: "Max",
                 time: "3 hours ago",
                 text: "Corgi squad assemble! Short legs, unlimited energy.",
                 image: "content_dog3", following: false, likes: "1.6k", comments: "8", shares: "301", liked: false),
        // Lily — 2 posts
        Activity(id: "p_lily_1", userId: "u_lily", avatar: "avatar_user", name: "Lily",
                 time: "7 hours ago",
                 text: "Rainy day = indoor puzzle toys. Mochi solved it in 3 minutes flat.",
                 image: "feed_post_08", following: false, likes: "634", comments: "5", shares: "98", liked: false),
        Activity(id: "p_lily_2", userId: "u_lily", avatar: "avatar_user", name: "Lily",
                 time: "1 day ago",
                 text: "Met the cutest terrier mix at the dog café today. Instant besties.",
                 image: "content_post2", following: false, likes: "891", comments: "6", shares: "143", liked: true),
        // William — 1 post
        Activity(id: "p_william_1", userId: "u_william", avatar: "feed_post_01", name: "William",
                 time: "8 hours ago",
                 text: "Shiba zoomies at 6 AM. Pretty sure the neighbors adore us.",
                 image: "feed_post_09", following: false, likes: "1.4k", comments: "4", shares: "256", liked: false),
        // Olivia — 2 posts
        Activity(id: "p_olivia_1", userId: "u_olivia", avatar: "feed_post_02", name: "Olivia",
                 time: "9 hours ago",
                 text: "Foster pup found a forever home! Bittersweet happy tears today.",
                 image: "feed_post_10", following: true, likes: "3.1k", comments: "7", shares: "520", liked: true),
        Activity(id: "p_olivia_2", userId: "u_olivia", avatar: "feed_post_02", name: "Olivia",
                 time: "3 days ago",
                 text: "Shelter volunteer day — so many good boys still waiting for families.",
                 image: "feed_post_02", following: true, likes: "1.2k", comments: "5", shares: "198", liked: false),
        // Leo — 1 post
        Activity(id: "p_leo_1", userId: "u_leo", avatar: "feed_post_03", name: "Leo",
                 time: "11 hours ago",
                 text: "Midnight city stroll. Streetlights, cool air, and a calm leash.",
                 image: "feed_post_03", following: false, likes: "723", comments: "3", shares: "112", liked: false),
        // Grace — 2 posts
        Activity(id: "p_grace_1", userId: "u_grace", avatar: "feed_post_04", name: "Grace",
                 time: "12 hours ago",
                 text: "Puppy playdate chaos — ten pups, zero personal space, 100% joy.",
                 image: "feed_post_04", following: true, likes: "1.9k", comments: "6", shares: "334", liked: true),
        Activity(id: "p_grace_2", userId: "u_grace", avatar: "feed_post_04", name: "Grace",
                 time: "2 days ago",
                 text: "Socialization tip: start with one calm buddy before the full party.",
                 image: "feed_post_05", following: true, likes: "867", comments: "4", shares: "155", liked: false),
        // Noah — 1 post
        Activity(id: "p_noah_1", userId: "u_noah", avatar: "feed_post_05", name: "Noah",
                 time: "1 day ago",
                 text: "First hike with Luna — she insisted on carrying her own backpack!",
                 image: "feed_post_01", following: false, likes: "1.0k", comments: "5", shares: "189", liked: true),
    ]

    /// Signed-in user's published posts (prepended to Feed Tab); loaded per account session.
    private(set) static var userPublishedPosts: [Activity] = []

    /// Test account has rich social/chat data; new users start empty.
    static var hasRichProfile: Bool { AppSession.shared.isTestAccount }

    private static let userPostsStorageKey = "user.publishedPosts"

    /// Demo feed order — shuffled once per app launch.
    private static let shuffledDemoFeedPosts: [Activity] = {
        var posts = feedPosts
        posts.shuffle()
        return posts
    }()

    /// Feed Tab: user posts first, then shuffled demo posts (blocked users hidden).
    static var feedPostsForFeedTab: [Activity] {
        visiblePosts(userPublishedPosts + shuffledDemoFeedPosts)
    }

    /// Feed Tab Followed segment — posts from followed users only.
    static var followedFeedPosts: [Activity] {
        visiblePosts(feedPostsForFeedTab.filter { isFollowing(userId: $0.userId) })
    }

    /// Posts published by the current account (Me Tab).
    static var currentUserPosts: [Activity] { userPublishedPosts }

    static let currentUserId = "u_me"

    static func currentFeedUser() -> FeedUser {
        let acct = AppSession.shared.current
        let avatar = acct?.avatarAsset ?? "avatar_user"
        if hasRichProfile {
            return FeedUser(
                id: currentUserId,
                avatar: avatar,
                name: acct?.displayName ?? "Me",
                bio: acct?.bio ?? "Dog walking lover · weekend park regular",
                coverImage: avatar,
                friends: testFriends.count,
                followed: testFollowed.count,
                fans: testFans.count)
        }
        return FeedUser(
            id: currentUserId,
            avatar: avatar,
            name: acct?.displayName ?? "Me",
            bio: acct?.bio ?? "No introduction yet~",
            coverImage: avatar,
            friends: 0, followed: 0, fans: 0)
    }

    /// Social stat counts shown on Me Tab — matches secondary list lengths.
    static var friendsCount: Int { friends.count }
    static var followedCount: Int { followed.count }
    static var fansCount: Int { fans.count }

    // MARK: - Account session lifecycle

    static func loadUserContentForCurrentAccount() {
        guard AppSession.shared.current != nil else {
            clearSessionContent()
            return
        }
        loadInteractionStateForCurrentAccount()
        resetLiveFollowStateForCurrentAccount()
        if hasRichProfile {
            userPublishedPosts = loadStoredUserPosts() ?? [testAccountSeedPost]
            if loadStoredUserPosts() == nil { persistUserPosts() }
        } else {
            userPublishedPosts = loadStoredUserPosts() ?? []
        }
    }

    static func clearSessionContent() {
        userPublishedPosts = []
        followedUserIds = []
        likedPostIds = []
        joinedActivityTitles = []
        followedLiveRoomIds = []
        chatHistories = [:]
        aiChatMessages = []
        postComments = [:]
    }

    private static func loadStoredUserPosts() -> [Activity]? {
        guard let data = AppSession.shared.storage?.data(userPostsStorageKey),
              let posts = try? JSONDecoder().decode([Activity].self, from: data) else { return nil }
        return posts
    }

    private static func persistUserPosts() {
        guard let data = try? JSONEncoder().encode(userPublishedPosts) else { return }
        AppSession.shared.storage?.set(data, for: userPostsStorageKey)
    }

    private static var testAccountSeedPost: Activity {
        let user = AppSession.shared.current
        return Activity(
            id: "p_me_demo",
            userId: currentUserId,
            avatar: user?.avatarAsset ?? "content_dog1",
            name: user?.displayName ?? AppSession.testAccountDisplayName,
            time: "2 days ago",
            text: "Sunday morning pack walk at Riverside Park — Biscuit made three new friends! Who else is bringing their pup next week?",
            image: "content_dog1",
            following: false,
            likes: "128",
            comments: "6",
            shares: "24",
            liked: true)
    }

    static func isOwnPost(_ activity: Activity) -> Bool {
        activity.userId == currentUserId
    }

    @discardableResult
    static func deleteUserPost(postId: String) -> Bool {
        guard let index = userPublishedPosts.firstIndex(where: { $0.id == postId }) else { return false }
        let post = userPublishedPosts[index]
        if let accountID = AppSession.shared.current?.id {
            PostImageStore.deleteImage(named: post.image, accountID: accountID)
        }
        userPublishedPosts.remove(at: index)
        persistUserPosts()
        if likedPostIds.remove(postId) != nil {
            persistInteractionState()
        }
        NotificationCenter.default.post(name: .userPostDidDelete, object: postId)
        return true
    }

    @discardableResult
    static func addUserPost(title: String, content: String, photo: UIImage? = nil) -> Activity {
        let body: String
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        switch (trimmedTitle.isEmpty, trimmedContent.isEmpty) {
        case (false, false): body = "\(trimmedTitle)\n\(trimmedContent)"
        case (false, true): body = trimmedTitle
        case (true, false): body = trimmedContent
        case (true, true): body = "Shared a new moment with my dog~"
        }

        let imageKey: String
        if let photo, let accountID = AppSession.shared.current?.id,
           let saved = PostImageStore.save(photo, accountID: accountID) {
            imageKey = saved
        } else {
            imageKey = ""
        }

        let user = currentFeedUser()
        let post = Activity(
            id: "p_user_\(UUID().uuidString)",
            userId: currentUserId,
            avatar: user.avatar,
            name: user.name,
            time: "Just now",
            text: body,
            image: imageKey,
            following: false,
            likes: "0",
            comments: "0",
            shares: "0",
            liked: false)
        userPublishedPosts.insert(post, at: 0)
        persistUserPosts()
        NotificationCenter.default.post(name: .userPostDidPublish, object: post)
        return post
    }

    static func feedUser(for activity: Activity) -> FeedUser? {
        if activity.userId == currentUserId { return currentFeedUser() }
        return user(id: activity.userId)
    }

    /// Home preview — first two community cards (blocked users hidden).
    static var activities: [Activity] { Array(visiblePosts(feedPosts).prefix(2)) }

    // MARK: - Block / unblock (per account)

    static func isBlocked(name: String) -> Bool {
        AppSession.shared.blockedNames.contains(name)
    }

    static func blockUser(named name: String) {
        guard !name.isEmpty, !isBlocked(name: name) else { return }
        AppSession.shared.block(name)
        if let userId = userId(forName: name) {
            setFollowing(false, for: userId)
        }
        NotificationCenter.default.post(name: .blockStateDidChange, object: name)
    }

    static func unblockUser(named name: String) {
        guard isBlocked(name: name) else { return }
        AppSession.shared.unblock(name)
        NotificationCenter.default.post(name: .blockStateDidChange, object: name)
    }

    private static func visiblePosts(_ posts: [Activity]) -> [Activity] {
        posts.filter { !isBlocked(name: $0.name) }
    }

    private static func visibleSocial(_ users: [SocialUser]) -> [SocialUser] {
        users.filter { !isBlocked(name: $0.name) }
    }

    // MARK: - Follow state (per account; shared by activity cards & user profiles)

    private static var followedUserIds: Set<String> = []

    private static let followedStorageKey = "demo.followedUserIds"
    private static let likedStorageKey = "demo.likedPostIds"
    private static let joinedStorageKey = "demo.joinedActivityTitles"

    private static func loadInteractionStateForCurrentAccount() {
        if let stored = AppSession.shared.storage?.stringArray(followedStorageKey) {
            followedUserIds = Set(stored)
        } else if hasRichProfile {
            followedUserIds = Set(feedPosts.filter(\.following).map(\.userId))
        } else {
            followedUserIds = []
        }

        if let stored = AppSession.shared.storage?.stringArray(likedStorageKey) {
            likedPostIds = Set(stored)
        } else if hasRichProfile {
            likedPostIds = Set(feedPosts.filter(\.liked).map(\.id))
        } else {
            likedPostIds = []
        }

        if let stored = AppSession.shared.storage?.stringArray(joinedStorageKey) {
            joinedActivityTitles = Set(stored)
        } else if hasRichProfile {
            joinedActivityTitles = ["Late-night dog walking"]
        } else {
            joinedActivityTitles = []
        }

        loadChatHistoriesForCurrentAccount()
        loadAIChatMessagesForCurrentAccount()
        resetReadConversationsForCurrentAccount()
        resetPostCommentsForSession()

        if AppSession.shared.storage?.stringArray(followedStorageKey) == nil {
            persistInteractionState()
        }
    }

    private static func persistInteractionState() {
        guard AppSession.shared.current != nil else { return }
        AppSession.shared.storage?.set(Array(followedUserIds), for: followedStorageKey)
        AppSession.shared.storage?.set(Array(likedPostIds), for: likedStorageKey)
        AppSession.shared.storage?.set(Array(joinedActivityTitles), for: joinedStorageKey)
    }

    /// In-process only — chat histories reset on cold start / re-login.
    private static func loadChatHistoriesForCurrentAccount() {
        chatHistories = hasRichProfile ? seedTestChatHistories() : [:]
        ensureSystemChatHistory()
    }

    static func isFollowing(userId: String) -> Bool {
        followedUserIds.contains(userId)
    }

    static func setFollowing(_ following: Bool, for userId: String) {
        let changed: Bool
        if following {
            changed = followedUserIds.insert(userId).inserted
        } else {
            changed = followedUserIds.remove(userId) != nil
        }
        guard changed else { return }
        persistInteractionState()
        NotificationCenter.default.post(
            name: .followStateDidChange,
            object: nil,
            userInfo: [FollowUserInfoKey.userId: userId, FollowUserInfoKey.following: following])
    }

    // MARK: - Like state (per account; shared by activity cards per post id)

    private static var likedPostIds: Set<String> = []
    private static var joinedActivityTitles: Set<String> = []

    static func isLiked(postId: String) -> Bool {
        likedPostIds.contains(postId)
    }

    static func setLiked(_ liked: Bool, for postId: String) {
        let changed: Bool
        if liked {
            changed = likedPostIds.insert(postId).inserted
        } else {
            changed = likedPostIds.remove(postId) != nil
        }
        guard changed else { return }
        persistInteractionState()
        NotificationCenter.default.post(
            name: .likeStateDidChange,
            object: nil,
            userInfo: [LikePostInfoKey.postId: postId, LikePostInfoKey.liked: liked])
    }

    static func user(id: String) -> FeedUser? {
        feedUsers.first { $0.id == id }
    }

    static func user(named name: String) -> FeedUser? {
        feedUsers.first { $0.name == name }
    }

    static func posts(for userId: String) -> [Activity] {
        feedPosts.filter { $0.userId == userId }
    }

    static func comments(for postId: String) -> [PostComment] {
        postComments[postId] ?? []
    }

    static func appendComment(_ comment: PostComment, for postId: String) {
        var list = postComments[postId] ?? []
        list.append(comment)
        postComments[postId] = list
    }

    // MARK: - Per-post comments (in-process session only; seeded for demo posts)

    private static var postComments: [String: [PostComment]] = [:]

    private static func resetPostCommentsForSession() {
        postComments = seedPostComments()
    }

    private static func seedPostComments() -> [String: [PostComment]] {
        func c(_ uid: String, _ text: String) -> PostComment {
            let u = feedUsers.first { $0.id == uid }!
            return PostComment(userId: uid, avatar: u.avatar, name: u.name, text: text)
        }
        return [
            "p_emma_1": [
                c("u_james", "That golden coat in the morning light is gorgeous!"),
                c("u_sophie", "Riverside Park is perfect for meetups — was it crowded?"),
                c("u_max", "Five new friends in one walk? Biscuit is a social butterfly."),
                c("u_lily", "Love seeing happy pups at the park!"),
                c("u_grace", "Morning walks are the best energy boost."),
            ],
            "p_emma_2": [
                c("u_noah", "Haha, my dog shredded a rope toy in one afternoon too."),
                c("u_william", "10/10 durability rating made me laugh out loud."),
                c("u_olivia", "Worth it for the tail wags though!"),
            ],
            "p_james_1": [
                c("u_emma", "Hill training is no joke — Dash looks so focused!"),
                c("u_leo", "That uphill 'stay' is seriously impressive."),
                c("u_sophie", "Huskies + hills = ultimate workout combo."),
                c("u_max", "Proud dad moment well earned!"),
                c("u_grace", "Any tips for teaching stay on slopes?"),
                c("u_noah", "The scenery on that trail looks amazing."),
                c("u_lily", "My pup would have sprinted straight to the top."),
            ],
            "p_sophie_1": [
                c("u_emma", "Beach sunset + dogs = pure happiness."),
                c("u_lily", "Sand paws are the cutest mess ever."),
                c("u_william", "Which beach is this? Looks incredible."),
                c("u_olivia", "Coco's tail must have been wagging nonstop."),
                c("u_james", "Need to plan a beach walk with Dash."),
                c("u_noah", "Golden hour lighting on the water is perfect."),
            ],
            "p_sophie_2": [
                c("u_grace", "Count me in for next weekend!"),
                c("u_max", "Group walks are the best for tiring out corgis."),
                c("u_leo", "What time do you usually start on Sundays?"),
                c("u_emma", "Three-dog squad goals in this photo!"),
            ],
            "p_max_1": [
                c("u_sophie", "Corgi squad! Those ears are everything."),
                c("u_emma", "Short legs, unlimited energy — so true."),
                c("u_william", "How do you get them all to pose together?"),
                c("u_olivia", "This made my day — look at those smiles!"),
                c("u_james", "My husky would try to herd this whole group."),
                c("u_lily", "The grass field looks perfect for zoomies."),
                c("u_noah", "Need a corgi meetup like this near me."),
                c("u_leo", "Best squad photo I've seen all week."),
            ],
            "p_lily_1": [
                c("u_max", "Mochi is a puzzle genius! 3 minutes is wild."),
                c("u_grace", "Rainy day brain games are underrated."),
                c("u_emma", "What puzzle toy is that? Need recs."),
                c("u_sophie", "Indoor enrichment saves my sanity on storm days."),
                c("u_olivia", "Smart pup! Mental exercise counts as a walk."),
            ],
            "p_lily_2": [
                c("u_william", "Dog cafés are the best — which one is this?"),
                c("u_james", "Terrier mixes have the best personalities."),
                c("u_sophie", "Instant besties is the cutest caption."),
                c("u_grace", "Love the cozy café vibe in the photo."),
                c("u_noah", "Luna would have ordered every treat on the menu."),
                c("u_olivia", "So wholesome — more dog café dates please!"),
            ],
            "p_william_1": [
                c("u_leo", "6 AM zoomies gang — I feel this."),
                c("u_james", "Shiba energy at dawn is a whole experience."),
                c("u_emma", "The living room blur says it all!"),
                c("u_max", "At least the neighbors get a free morning show."),
            ],
            "p_olivia_1": [
                c("u_emma", "Congratulations! Foster wins are the best tears."),
                c("u_grace", "This photo radiates pure joy — so happy for them."),
                c("u_lily", "You're doing amazing work. Thank you for fostering."),
                c("u_sophie", "Forever home day never gets old."),
                c("u_noah", "The pup's smile in this shot melted me."),
                c("u_james", "Rescue heroes like you make all the difference."),
                c("u_max", "Bittersweet in the best way — happy adoption day!"),
            ],
            "p_olivia_2": [
                c("u_william", "Volunteer days are tough but so rewarding."),
                c("u_leo", "Every good boy deserves a family like this."),
                c("u_sophie", "Thank you for showing the shelter pups love."),
                c("u_emma", "How can others sign up to volunteer?"),
                c("u_james", "The shelter pups in this photo are adorable."),
            ],
            "p_leo_1": [
                c("u_sophie", "Night walks in the city hit different — so peaceful."),
                c("u_emma", "Love the streetlight glow on the pavement."),
                c("u_noah", "Midnight strolls are underrated bonding time."),
            ],
            "p_grace_1": [
                c("u_lily", "Ten pups and zero personal space — chaos I want."),
                c("u_max", "Puppy playdate heaven! Who hosted this?"),
                c("u_emma", "The pile of puppies in this photo is everything."),
                c("u_olivia", "Socialization done right — so many happy faces."),
                c("u_william", "I can almost hear the barking from here."),
                c("u_james", "This is why puppy classes are worth it."),
            ],
            "p_grace_2": [
                c("u_james", "Great tip — one calm buddy first makes a huge difference."),
                c("u_sophie", "Starting small saved us at our first playdate."),
                c("u_lily", "Solid advice for nervous pups."),
                c("u_noah", "Luna was the calm buddy for our neighbor's puppy!"),
            ],
            "p_noah_1": [
                c("u_sophie", "Luna with a backpack is the cutest hiking partner."),
                c("u_emma", "First hike memories are always special."),
                c("u_grace", "Trail hikes build such great confidence in pups."),
                c("u_olivia", "That mountain view behind you is stunning."),
                c("u_max", "She really carried her own pack? Adorable overachiever."),
            ],
        ]
    }

    // MARK: - Home / live / chat (unchanged modules)

    struct Popular {
        let image: String
        let title: String
        let meta: String
        let avatars: [String]
        let extra: Int
        var joined: Bool
    }

    struct LiveRoom {
        let id: String
        let cover: String
        let title: String
        let host: String
        let hostAvatar: String
        let viewers: String
        let location: String
        /// Bundled mp4 asset name (no extension), from `Resources/LiveVideos`.
        let videoAsset: String
    }

    struct LiveComment {
        let avatar: String
        let name: String
        let text: String
    }

    /// Per-room danmaku pool; each hot live screen draws random comments from its own list.
    static func liveCommentPool(forRoomId roomId: String) -> [LiveComment] {
        switch roomId {
        case "live_01":
            return [
                c("feed_post_02", "Olivia", "Fall leaves + golden fluff = perfect stream"),
                c("feed_post_03", "Leo", "That belly rub looks so relaxing"),
                c("avatar_a", "Maya", "Autumn dog walks are the best"),
                c("feed_post_04", "Grace", "Golden retriever energy is unmatched"),
                c("avatar_b", "James", "Need this cozy vibe today"),
                c("feed_post_05", "Noah", "The leaves crunching must sound amazing"),
                c("feed_post_06", "Emma", "Couple goals with their pup"),
                c("avatar_c", "Zoe", "My retriever does the same flop pose"),
                c("feed_post_07", "Sophia", "Best autumn live so far"),
                c("feed_post_08", "Mia", "Sending belly rubs through the screen"),
            ]
        case "live_02":
            return [
                c("feed_post_01", "William", "Coffee and poodle cuddles, yes please"),
                c("feed_post_03", "Leo", "That mug is almost as big as the pup"),
                c("avatar_a", "Maya", "Outdoor cafe with dogs is elite"),
                c("feed_post_04", "Grace", "My poodle hides in my jacket too"),
                c("avatar_b", "James", "This is the coziest live today"),
                c("feed_post_05", "Noah", "What cafe is this? Looks chill"),
                c("feed_post_06", "Emma", "Tiny ears peeking out, adorable"),
                c("avatar_c", "Zoe", "Poodle parent life looks perfect"),
                c("feed_post_07", "Sophia", "Coffee date with a furry friend"),
                c("feed_post_09", "Ava", "Need a pup in my lap right now"),
            ]
        case "live_03":
            return [
                c("feed_post_02", "Olivia", "Matching plaid outfits are everything"),
                c("feed_post_01", "William", "City walk fit check passed"),
                c("avatar_a", "Maya", "The dog coat matches the jacket, love it"),
                c("feed_post_04", "Grace", "So stylish for a sidewalk stroll"),
                c("avatar_b", "James", "Plaid squad rolling through downtown"),
                c("feed_post_05", "Noah", "Best dressed duo on this stream"),
                c("feed_post_06", "Emma", "Urban dog walk inspo right here"),
                c("avatar_c", "Zoe", "That little pup struts so confidently"),
                c("feed_post_08", "Mia", "Fashion walk with a furry model"),
                c("feed_post_10", "Lily", "City sidewalks + cute pup = win"),
            ]
        case "live_04":
            return [
                c("feed_post_02", "Olivia", "Cavalier energy is so elegant"),
                c("feed_post_03", "Leo", "White outfit + fluffy pup, stunning"),
                c("avatar_a", "Maya", "That spaniel is trotting with joy"),
                c("feed_post_04", "Grace", "Graceful walk, graceful dog"),
                c("avatar_b", "James", "Cavalier parents unite in chat"),
                c("feed_post_05", "Noah", "The leash coordination is on point"),
                c("feed_post_06", "Emma", "Such a happy little trot"),
                c("avatar_c", "Zoe", "City stroll goals for sure"),
                c("feed_post_07", "Sophia", "That pup looks so well behaved"),
                c("feed_post_09", "Ava", "Elegant live, elegant vibes"),
            ]
        case "live_05":
            return [
                c("feed_post_01", "William", "Two poodles, double the chaos"),
                c("feed_post_02", "Olivia", "Both pups look so fluffy today"),
                c("avatar_a", "Maya", "Managing two leashes like a pro"),
                c("feed_post_04", "Grace", "City walk with the poodle squad"),
                c("avatar_b", "James", "One brown, one white, perfect pair"),
                c("feed_post_05", "Noah", "That coat draped over shoulders is chic"),
                c("feed_post_06", "Emma", "Twin poodle parade on the sidewalk"),
                c("avatar_c", "Zoe", "Which poodle is the troublemaker?"),
                c("feed_post_08", "Mia", "Love seeing multi-dog walks done right"),
                c("feed_post_10", "Lily", "Poodle parents make it look easy"),
            ]
        case "live_06":
            return [
                c("feed_post_01", "William", "Golden retriever zoomies in the park"),
                c("feed_post_02", "Olivia", "Kid and dog best friends forever"),
                c("avatar_a", "Maya", "That sunny field looks perfect"),
                c("feed_post_04", "Grace", "Golden retriever playtime is pure joy"),
                c("avatar_b", "James", "Park days hit different with a big dog"),
                c("feed_post_05", "Noah", "The pup is keeping up so well"),
                c("feed_post_07", "Sophia", "Love this outdoor play live"),
                c("avatar_c", "Zoe", "Grass + sunshine + golden = heaven"),
                c("feed_post_08", "Mia", "My dog wants to join this playdate"),
                c("feed_post_09", "Ava", "Best park stream today"),
            ]
        case "live_07":
            return [
                c("feed_post_01", "William", "Bench cuddles with a happy pup"),
                c("feed_post_03", "Leo", "That red harness pops on camera"),
                c("avatar_a", "Maya", "Park bench hangout vibes are immaculate"),
                c("feed_post_04", "Grace", "The dog's smile made my day"),
                c("avatar_b", "James", "Curly hair and curly pup energy"),
                c("feed_post_05", "Noah", "Perfect afternoon in the park"),
                c("feed_post_06", "Emma", "That tongue-out happy face though"),
                c("avatar_c", "Zoe", "Wish I was on that bench too"),
                c("feed_post_08", "Mia", "Wholesome live, needed this"),
                c("feed_post_10", "Lily", "Park bench + pup = instant calm"),
            ]
        case "live_08":
            return [
                c("feed_post_02", "Olivia", "Golden retriever hugs are therapy"),
                c("feed_post_03", "Leo", "That hug looks so warm and genuine"),
                c("avatar_a", "Maya", "Big dog, big love on this stream"),
                c("feed_post_04", "Grace", "Turf cuddles with a golden, yes"),
                c("avatar_b", "James", "My retriever hugs me exactly like this"),
                c("feed_post_05", "Noah", "Emotional support golden retriever live"),
                c("feed_post_06", "Emma", "The bond here is so sweet"),
                c("avatar_c", "Zoe", "Sending hugs to everyone in chat"),
                c("feed_post_07", "Sophia", "Best cuddle session on live today"),
                c("feed_post_09", "Ava", "Golden retriever parents relate hard"),
            ]
        case "live_09":
            return [
                c("feed_post_01", "William", "Training tips are actually helpful"),
                c("feed_post_02", "Olivia", "Positive reinforcement looks great here"),
                c("avatar_a", "Maya", "Golden retriever learns so fast"),
                c("feed_post_04", "Grace", "Taking notes for my pup's training"),
                c("avatar_b", "James", "Consistency is key, great demo"),
                c("feed_post_05", "Noah", "Love this training-focused live"),
                c("feed_post_06", "Emma", "The pup is so focused on the handler"),
                c("avatar_c", "Zoe", "Never-ending process but worth it"),
                c("feed_post_08", "Mia", "More training streams please"),
                c("feed_post_10", "Lily", "Reward timing looks spot on"),
            ]
        case "live_10":
            return [
                c("feed_post_01", "William", "Great Dane POV is hilarious"),
                c("feed_post_02", "Olivia", "That harlequin coat is stunning"),
                c("avatar_a", "Maya", "Big dog, big steps, big personality"),
                c("feed_post_04", "Grace", "Leash cam makes me feel like I'm walking too"),
                c("avatar_b", "James", "Great Dane gang in the chat"),
                c("feed_post_05", "Noah", "The spots are so unique on this pup"),
                c("feed_post_06", "Emma", "Morning walk energy is strong"),
                c("avatar_c", "Zoe", "Another dog in the background, double fun"),
                c("feed_post_07", "Sophia", "POV walks are my favorite format"),
                c("feed_post_09", "Ava", "That pink leash is a mood"),
            ]
        default:
            return [
                c("avatar_a", "Maya", "Love this live stream"),
                c("avatar_b", "James", "Such a good dog walking vibe"),
                c("avatar_c", "Zoe", "Hello from the chat"),
            ]
        }
    }

    private static func c(_ avatar: String, _ name: String, _ text: String) -> LiveComment {
        LiveComment(avatar: avatar, name: name, text: text)
    }

    enum ConvKind { case system, ai, user }
    struct Conversation {
        let kind: ConvKind
        let avatar: String
        let name: String
        let last: String
        let time: String
        var unread: Int
    }

    static let avatarStack = ["avatar_a", "avatar_b", "avatar_c"]

    private static let popularBase: [Popular] = [
        Popular(image: "content_dog1", title: "Sunny Park Pack", meta: "500m,  7pm tonight",
                avatars: avatarStack, extra: 2, joined: false),
        Popular(image: "content_dog2", title: "Late-night dog walking", meta: "800m,  10:30pm tonight",
                avatars: avatarStack, extra: 2, joined: false),
        Popular(image: "content_dog3", title: "Shiba Inu Party", meta: "400m,  25minutes",
                avatars: avatarStack, extra: 2, joined: false),
    ]

    static var popular: [Popular] {
        popularBase.map { item in
            Popular(image: item.image, title: item.title, meta: item.meta,
                    avatars: item.avatars, extra: item.extra,
                    joined: joinedActivityTitles.contains(item.title))
        }
    }

    static let liveRooms: [LiveRoom] = [
        LiveRoom(
            id: "live_01", cover: "content_dog1", title: "Autumn Golden Retriever",
            host: "William", hostAvatar: "feed_post_01", viewers: "3.2k",
            location: "Fall Leaves & Golden Pup",
            videoAsset: "live_video_01"),
        LiveRoom(
            id: "live_02", cover: "content_dog2", title: "Coffee Break with My Poodle",
            host: "Olivia", hostAvatar: "feed_post_02", viewers: "1.8k",
            location: "Outdoor Cafe w/ Pup",
            videoAsset: "live_video_02"),
        LiveRoom(
            id: "live_03", cover: "content_dog3", title: "Matching Plaid City Walk",
            host: "Leo", hostAvatar: "feed_post_03", viewers: "2.4k",
            location: "Plaid Pup Downtown",
            videoAsset: "live_video_03"),
        LiveRoom(
            id: "live_04", cover: "feed_post_04", title: "Cavalier Spaniel Stroll",
            host: "Grace", hostAvatar: "feed_post_04", viewers: "960",
            location: "Cavalier City Walk",
            videoAsset: "live_video_04"),
        LiveRoom(
            id: "live_05", cover: "feed_post_05", title: "Walking My Two Poodles",
            host: "Noah", hostAvatar: "feed_post_05", viewers: "1.1k",
            location: "Twin Poodles Downtown",
            videoAsset: "live_video_05"),
        LiveRoom(
            id: "live_06", cover: "feed_post_06", title: "Park Play with Golden Retriever",
            host: "Emma", hostAvatar: "feed_post_06", viewers: "740",
            location: "Sunny Park Playtime",
            videoAsset: "live_video_06"),
        LiveRoom(
            id: "live_07", cover: "feed_post_07", title: "Park Bench Cuddles",
            host: "Sophia", hostAvatar: "feed_post_07", viewers: "2.1k",
            location: "Bench Hangout Live",
            videoAsset: "live_video_07"),
        LiveRoom(
            id: "live_08", cover: "feed_post_08", title: "Golden Retriever Hugs",
            host: "Mia", hostAvatar: "feed_post_08", viewers: "530",
            location: "Turf Cuddle Time",
            videoAsset: "live_video_08"),
        LiveRoom(
            id: "live_09", cover: "feed_post_09", title: "Golden Retriever Training",
            host: "Ava", hostAvatar: "feed_post_09", viewers: "1.5k",
            location: "Dog Training Session",
            videoAsset: "live_video_09"),
        LiveRoom(
            id: "live_10", cover: "feed_post_10", title: "Great Dane Walk POV",
            host: "James", hostAvatar: "avatar_b", viewers: "890",
            location: "Great Dane Leash Cam",
            videoAsset: "live_video_10"),
    ]

    // MARK: - Live follow (in-process; reset on each login — test account defaults to 2)

    private static var followedLiveRoomIds: Set<String> = []
    private static let testAccountDefaultLiveFollows: Set<String> = ["live_01", "live_02"]

    private static func resetLiveFollowStateForCurrentAccount() {
        followedLiveRoomIds = hasRichProfile ? testAccountDefaultLiveFollows : []
    }

    static func isFollowingLive(roomId: String) -> Bool {
        followedLiveRoomIds.contains(roomId)
    }

    static func setFollowingLive(_ following: Bool, for roomId: String) {
        let changed: Bool
        if following {
            changed = followedLiveRoomIds.insert(roomId).inserted
        } else {
            changed = followedLiveRoomIds.remove(roomId) != nil
        }
        guard changed else { return }
        NotificationCenter.default.post(name: .liveFollowStateDidChange, object: roomId)
    }

    static var followedLiveRooms: [LiveRoom] {
        liveRooms.filter { followedLiveRoomIds.contains($0.id) }
    }

    private static let aiConversationName = "AI Assistant"
    private static let aiConversationKey = "__ai__"

    /// In-process only — read state resets on cold start / re-login.
    private static var readConversationKeys: Set<String> = []

    private static let testConversations: [Conversation] = [
        Conversation(kind: .system, avatar: "", name: "System", last: "Spring dog walking activitie...", time: "10:30", unread: 1),
        Conversation(kind: .ai, avatar: "ai_robot", name: "AI Assistant", last: "Chat with AI about dogs", time: "9:20", unread: 1),
        Conversation(kind: .user, avatar: "avatar_user", name: "Lily", last: "Want to walk the dog together?", time: "yesterday", unread: 1),
        Conversation(kind: .user, avatar: "avatar_b", name: "James", last: "I've shared the link to the ne...", time: "5 hours ago", unread: 1),
        Conversation(kind: .user, avatar: "feed_post_01", name: "William", last: "Your dog walking request ha...", time: "Just", unread: 0),
    ]

    private static let newUserConversations: [Conversation] = [
        Conversation(
            kind: .system,
            avatar: "",
            name: "System",
            last: "Welcome to Harper! Explore the community and find walking buddies.",
            time: "Just now",
            unread: 1),
    ]

    static var conversations: [Conversation] {
        let base: [Conversation]
        if hasRichProfile {
            base = testConversations
        } else {
            var items = newUserConversations
            if let preview = aiConversationPreview() {
                items.append(preview)
            }
            base = items
        }
        return base
            .filter { $0.kind != .user || !isBlocked(name: $0.name) }
            .map { applyReadState($0) }
    }

    private static func applyReadState(_ conversation: Conversation) -> Conversation {
        var copy = conversation
        if readConversationKeys.contains(conversationKey(for: conversation.name)) {
            copy.unread = 0
        }
        return copy
    }

    static func conversationKey(for name: String) -> String {
        if name == "System" { return systemChatPeerId }
        if name == aiConversationName { return aiConversationKey }
        return userId(forName: name) ?? "name:\(name)"
    }

    /// Clears unread for a conversation and notifies list + tab badge listeners.
    static func markConversationRead(name: String) {
        let key = conversationKey(for: name)
        guard !readConversationKeys.contains(key) else { return }
        readConversationKeys.insert(key)
        NotificationCenter.default.post(name: .chatUnreadDidChange, object: nil)
    }

    private static func resetReadConversationsForCurrentAccount() {
        readConversationKeys = []
    }

    private static func aiConversationPreview() -> Conversation? {
        guard let last = aiChatMessages.last else { return nil }
        let preview = last.text.replacingOccurrences(of: "\n", with: " ")
        let truncated = preview.count > 40 ? String(preview.prefix(37)) + "..." : preview
        return Conversation(
            kind: .ai,
            avatar: "ai_robot",
            name: "AI Assistant",
            last: truncated,
            time: last.time,
            unread: 0)
    }

    static var totalUnread: Int { conversations.reduce(0) { $0 + $1.unread } }

    // MARK: - AI chat (per-account; empty for new users until first message)

    struct ChatMessage: Codable {
        let text: String
        let fromUser: Bool
        let time: String
    }

    private static var aiChatMessages: [ChatMessage] = []

    private static func seedTestAIChatMessages() -> [ChatMessage] {
        [
            ChatMessage(text: "What's the best place to\nwalk today?", fromUser: true, time: "10:54 am"),
            ChatMessage(text: "The banks of the Seine in Paris~", fromUser: false, time: "10:56 am"),
        ]
    }

    /// In-process only — AI chat resets on cold start / re-login.
    private static func loadAIChatMessagesForCurrentAccount() {
        aiChatMessages = hasRichProfile ? seedTestAIChatMessages() : []
    }

    /// AI chat history for the current account; empty until the user sends a message.
    static func aiChatMessagesList() -> [ChatMessage] { aiChatMessages }

    static func appendAIChatMessage(_ message: ChatMessage) {
        aiChatMessages.append(message)
        NotificationCenter.default.post(name: .aiChatDidChange, object: nil)
    }

    // MARK: - Friend chat (per-user history; empty until first message for newly followed users)

    /// Stable storage key for the System conversation thread.
    static let systemChatPeerId = "__system__"

    private static var chatHistories: [String: [ChatMessage]] = [:]

    private static func seedTestChatHistories() -> [String: [ChatMessage]] {
        func peer(_ text: String, _ time: String) -> ChatMessage {
            ChatMessage(text: text, fromUser: false, time: time)
        }
        func me(_ text: String, _ time: String) -> ChatMessage {
            ChatMessage(text: text, fromUser: true, time: time)
        }
        return [
            "u_james": [
                me("Any good hill-training spots this week?", "9:10 am"),
                peer("Try the north trail — Dash and I do 'stay' drills there every morning.", "9:14 am"),
                me("Perfect, I'll bring treats for the uphill reps.", "9:18 am"),
                peer("I've shared the link to the new meetup group in the park chat.", "5 hours ago"),
            ],
            "u_sophie": [
                peer("Beach sunset walk tomorrow — you in?", "8:40 am"),
                me("Yes! What time are you heading out?", "8:45 am"),
                peer("6:30 pm at the west pier. Bring water for the pups.", "8:50 am"),
            ],
            "u_olivia": [
                me("Saw your foster success post — so happy for that pup!", "2 days ago"),
                peer("Thank you! Forever-home day never gets old.", "2 days ago"),
                peer("We're doing another shelter volunteer run Saturday if you want to join.", "yesterday"),
            ],
            "u_grace": [
                peer("Puppy playdate this Sunday — ten pups, zero personal space 😄", "11:20 am"),
                me("Count us in! Should we start with one calm buddy?", "11:25 am"),
                peer("Exactly — one calm buddy first, then the full party.", "11:30 am"),
            ],
            "u_lily": [
                me("Free this weekend for a park walk?", "yesterday"),
                peer("Want to walk the dog together?", "yesterday"),
            ],
            "u_william": [
                me("Is the Shiba meetup still on for Saturday?", "Just now"),
                peer("Your dog walking request has been accepted — see you at 4 pm!", "Just now"),
            ],
        ]
    }

    private static func defaultSystemWelcomeMessages() -> [ChatMessage] {
        if hasRichProfile {
            return [
                ChatMessage(
                    text: "Spring dog walking activities are now open! Join a pack walk near you this weekend.",
                    fromUser: false,
                    time: "10:30 am"),
            ]
        }
        return [
            ChatMessage(
                text: "Welcome to Harper! Explore the community, find walking buddies, and share your pup's best moments. Happy walking! 🐾",
                fromUser: false,
                time: "Just now"),
        ]
    }

    private static func ensureSystemChatHistory() {
        guard chatHistories[systemChatPeerId] == nil else { return }
        chatHistories[systemChatPeerId] = defaultSystemWelcomeMessages()
    }

    /// System chat history for the current account; seeded once per account, then persisted in-session.
    static func systemChatMessages() -> [ChatMessage] {
        ensureSystemChatHistory()
        return chatHistories[systemChatPeerId] ?? defaultSystemWelcomeMessages()
    }

    static func userId(forName name: String) -> String? {
        user(named: name)?.id
    }

    /// Resolves the per-account storage key for a chat thread.
    static func chatPeerId(peerName: String, userId explicitUserId: String?) -> String {
        if peerName == "System" { return systemChatPeerId }
        if let explicitUserId { return explicitUserId }
        if let resolved = Self.userId(forName: peerName) { return resolved }
        return "name:\(peerName)"
    }

    /// Per-account chat history; empty for new users until they send a message.
    static func chatMessages(forUserId userId: String) -> [ChatMessage] {
        chatHistories[userId] ?? []
    }

    static func chatMessages(peerName: String, userId: String?) -> [ChatMessage] {
        chatMessages(forUserId: chatPeerId(peerName: peerName, userId: userId))
    }

    static func chatMessages(forPeerName name: String) -> [ChatMessage] {
        chatMessages(peerName: name, userId: nil)
    }

    static func appendChatMessage(_ message: ChatMessage, forUserId userId: String) {
        var list = chatHistories[userId] ?? []
        list.append(message)
        chatHistories[userId] = list
    }

    struct SocialUser { let avatar: String; let name: String; let bio: String }

    private static let testFriends: [SocialUser] = [
        SocialUser(avatar: "avatar_b", name: "James", bio: "Husky trainer · early riser"),
        SocialUser(avatar: "feed_post_01", name: "William", bio: "Shiba Inu enthusiast"),
        SocialUser(avatar: "avatar_a", name: "Emma", bio: "Golden Retriever mom · sunrise walks"),
        SocialUser(avatar: "feed_post_02", name: "Olivia", bio: "Rescue dog advocate"),
    ]
    private static let testFollowed: [SocialUser] = [
        SocialUser(avatar: "avatar_poster", name: "Sophie", bio: "Love long walks 🐕"),
        SocialUser(avatar: "feed_post_04", name: "Grace", bio: "Puppy socializer"),
        SocialUser(avatar: "feed_post_02", name: "Olivia", bio: "Rescue dog advocate"),
    ]
    private static let testFans: [SocialUser] = [
        SocialUser(avatar: "avatar_user", name: "Lily", bio: "Weekend park walker"),
        SocialUser(avatar: "feed_post_05", name: "Noah", bio: "Trail hikes with Luna"),
    ]

    static var friends: [SocialUser] { visibleSocial(hasRichProfile ? testFriends : []) }
    static var followed: [SocialUser] { visibleSocial(hasRichProfile ? testFollowed : []) }
    static var fans: [SocialUser] { visibleSocial(hasRichProfile ? testFans : []) }

    /// Pending friend requests — test account only (blocked users hidden).
    static var friendRequests: [SocialUser] {
        visibleSocial(hasRichProfile ? testFriendRequests : [])
    }

    private static let testFriendRequests: [SocialUser] = [
        SocialUser(avatar: "avatar_c", name: "Max", bio: "Corgi dad · short legs, big heart"),
        SocialUser(avatar: "feed_post_03", name: "Leo", bio: "Night owl dog walker"),
        SocialUser(avatar: "avatar_poster", name: "Sophie", bio: "Love long walks 🐕"),
    ]
}
