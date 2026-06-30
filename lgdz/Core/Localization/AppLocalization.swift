import Foundation

extension Notification.Name {
    static let languageDidChange = Notification.Name("app.languageDidChange")
}

enum AppLanguage: String, CaseIterable {
    case english = "en"
    case french = "fr"
    case swedish = "sv"

    var displayCode: String {
        switch self {
        case .english: return "EN"
        case .french: return "FR"
        case .swedish: return "SV"
        }
    }
}

enum L10n {

    private static let storageKey = "app.language"

    static var current: AppLanguage {
        get {
            guard let raw = UserDefaults.standard.string(forKey: storageKey) else { return .english }
            if raw == "zh" {
                UserDefaults.standard.set(AppLanguage.english.rawValue, forKey: storageKey)
                return .english
            }
            guard let lang = AppLanguage(rawValue: raw) else { return .english }
            return lang
        }
        set {
            guard newValue != current else { return }
            UserDefaults.standard.set(newValue.rawValue, forKey: storageKey)
            NotificationCenter.default.post(name: .languageDidChange, object: nil)
        }
    }

    static func tr(_ key: String) -> String {
        strings[key]?[current] ?? strings[key]?[.english] ?? key
    }

    // MARK: - Tabs

    static var tabHome: String { tr("tab.home") }
    static var tabFeed: String { tr("tab.feed") }
    static var tabChat: String { tr("tab.chat") }
    static var tabMe: String { tr("tab.me") }

    // MARK: - Me

    static var meFriends: String { tr("me.friends") }
    static var meFollowed: String { tr("me.followed") }
    static var meFans: String { tr("me.fans") }
    static var meBalance: String { tr("me.balance") }
    static var meRecharge: String { tr("me.recharge") }
    static var mePost: String { tr("me.post") }
    static var meNoPosts: String { tr("me.noPosts") }
    static var meNoPostsSubtitle: String { tr("me.noPostsSubtitle") }
    static var meNoIntro: String { tr("me.noIntro") }

    // MARK: - Cards & actions

    static var follow: String { tr("card.follow") }
    static var following: String { tr("card.following") }
    static var deletePost: String { tr("card.delete") }
    static var join: String { tr("card.join") }
    static var joined: String { tr("card.joined") }
    static var more: String { tr("common.more") }

    // MARK: - Feed

    static var feedRecommend: String { tr("feed.recommend") }
    static var feedFollowed: String { tr("feed.followed") }
    static var feedEmptyTitle: String { tr("feed.emptyTitle") }
    static var feedEmptySubtitle: String { tr("feed.emptySubtitle") }

    // MARK: - Home

    static var homeWalkDiary: String { tr("home.walkDiary") }
    static var homeDogMatch: String { tr("home.dogMatch") }
    static var homePopular: String { tr("home.popular") }
    static var homeActivities: String { tr("home.activities") }
    static var homeBannerTitle: String { tr("home.bannerTitle") }
    static var homeBannerSubtitle: String { tr("home.bannerSubtitle") }
    static var homeJoinNow: String { tr("home.joinNow") }

    // MARK: - Post content

    static func postBody(id: String, fallback: String) -> String {
        postBodies[id]?[current] ?? fallback
    }

    static func postTime(id: String, fallback: String) -> String {
        postTimes[id]?[current] ?? fallback
    }

    // MARK: - Tables

    private static let strings: [String: [AppLanguage: String]] = [
        "tab.home": [.english: "Home", .french: "Accueil", .swedish: "Hem"],
        "tab.feed": [.english: "Feed", .french: "Fil", .swedish: "Flöde"],
        "tab.chat": [.english: "Chat", .french: "Chat", .swedish: "Chatt"],
        "tab.me": [.english: "Me", .french: "Moi", .swedish: "Jag"],
        "me.friends": [.english: "Friends", .french: "Amis", .swedish: "Vänner"],
        "me.followed": [.english: "Followed", .french: "Abonnements", .swedish: "Följer"],
        "me.fans": [.english: "Fans", .french: "Abonnés", .swedish: "Fans"],
        "me.balance": [.english: "Balance", .french: "Solde", .swedish: "Saldo"],
        "me.recharge": [.english: "Recharge", .french: "Recharger", .swedish: "Ladda"],
        "me.post": [.english: "Post", .french: "Publications", .swedish: "Inlägg"],
        "me.noPosts": [.english: "No posts yet", .french: "Aucune publication", .swedish: "Inga inlägg än"],
        "me.noPostsSubtitle": [
            .english: "Share your first dog-walking moment!",
            .french: "Partagez votre première promenade !",
            .swedish: "Dela ditt första hundpromenad-ögonblick!",
        ],
        "me.noIntro": [
            .english: "No introduction yet~",
            .french: "Pas encore de bio~",
            .swedish: "Ingen presentation ännu~",
        ],
        "card.follow": [.english: " Follow", .french: " Suivre", .swedish: " Följ"],
        "card.following": [.english: "Following", .french: "Abonné", .swedish: "Följer"],
        "card.delete": [.english: " Delete", .french: " Supprimer", .swedish: " Radera"],
        "card.join": [.english: "Join", .french: "Rejoindre", .swedish: "Gå med"],
        "card.joined": [.english: "Joined", .french: "Inscrit", .swedish: "Gick med"],
        "common.more": [.english: "More ", .french: "Plus ", .swedish: "Mer "],
        "feed.recommend": [.english: "Recommend", .french: "Pour vous", .swedish: "Rekommenderat"],
        "feed.followed": [.english: "Followed", .french: "Abonnements", .swedish: "Följer"],
        "feed.emptyTitle": [
            .english: "No followed posts yet",
            .french: "Aucune publication suivie",
            .swedish: "Inga följda inlägg än",
        ],
        "feed.emptySubtitle": [
            .english: "Follow someone in Recommend\nto see their updates here.",
            .french: "Suivez quelqu'un dans Pour vous\npour voir ses publications ici.",
            .swedish: "Följ någon i Rekommenderat\nför att se uppdateringar här.",
        ],
        "home.walkDiary": [.english: "Walk Diary", .french: "Journal de balade", .swedish: "Promenaddagbok"],
        "home.dogMatch": [.english: "Dog Buddy Match", .french: "Match canin", .swedish: "Hundkompis-match"],
        "home.popular": [.english: "Popular", .french: "Populaire", .swedish: "Populärt"],
        "home.activities": [
            .english: "Dog lovers' activities",
            .french: "Activités des amoureux des chiens",
            .swedish: "Hundälskares aktiviteter",
        ],
        "home.bannerTitle": [
            .english: "Spring\nLeash & Meet",
            .french: "Printemps\nLaisse & Rencontre",
            .swedish: "Vår\nKoppel & Träff",
        ],
        "home.bannerSubtitle": [
            .english: "Come join us!",
            .french: "Rejoignez-nous !",
            .swedish: "Kom och häng med!",
        ],
        "home.joinNow": [.english: "Join Now ", .french: "Rejoindre ", .swedish: "Gå med "],
    ]

    private static let postBodies: [String: [AppLanguage: String]] = [
        "p_emma_1": [
            .english: "Morning sunshine at Riverside Park — Biscuit made five new friends!",
            .french: "Soleil du matin au parc Riverside — Biscuit s'est fait cinq nouveaux amis !",
            .swedish: "Morgonsol i Riverside Park — Biscuit fick fem nya vänner!",
        ],
        "p_emma_2": [
            .english: "New rope toy test: 10/10 durability, 0/10 for my furniture.",
            .french: "Test du nouveau jouet en corde : 10/10 solidité, 0/10 pour mes meubles.",
            .swedish: "Test av nytt repspel: 10/10 hållbarhet, 0/10 för mina möbler.",
        ],
        "p_james_1": [
            .english: "Dash finally nailed 'stay' on our hill run. Proud dad moment.",
            .french: "Dash a enfin réussi « reste » en course en côte. Moment de fierté.",
            .swedish: "Dash klarade äntligen \"stanna\" på vår backlöpning. Stolt pappastund.",
        ],
        "p_sophie_1": [
            .english: "Beach sunset walk — sand paws and happy tail wags everywhere.",
            .french: "Balade au coucher du soleil — pattes sablonneuses et queues joyeuses.",
            .swedish: "Solnedgångspromenad på stranden — sandiga tassar och glada svansar överallt.",
        ],
        "p_sophie_2": [
            .english: "Sunday group walk! Who's joining us next weekend?",
            .french: "Balade de groupe dimanche ! Qui nous rejoint le week-end prochain ?",
            .swedish: "Söndagspromenad i grupp! Vem hänger med nästa helg?",
        ],
        "p_max_1": [
            .english: "Corgi squad assemble! Short legs, unlimited energy.",
            .french: "Escouade corgi au rapport ! Petites pattes, énergie illimitée.",
            .swedish: "Corgi-gänget samlas! Korta ben, obegränsad energi.",
        ],
        "p_lily_1": [
            .english: "Rainy day = indoor puzzle toys. Mochi solved it in 3 minutes flat.",
            .french: "Jour de pluie = jouets d'intelligence. Mochi a tout résolu en 3 minutes.",
            .swedish: "Regnig dag = pussel-leksaker inomhus. Mochi löste allt på 3 minuter.",
        ],
        "p_lily_2": [
            .english: "Met the cutest terrier mix at the dog café today. Instant besties.",
            .french: "Rencontré le terrier mix le plus mignon au café canin. Amis instantanés.",
            .swedish: "Träffade den sötaste terriermixen på hundcafét idag. Bästa vänner direkt.",
        ],
        "p_william_1": [
            .english: "Shiba zoomies at 6 AM. Pretty sure the neighbors adore us.",
            .french: "Zoomies de Shiba à 6 h. Les voisins nous adorent, sûrement.",
            .swedish: "Shiba-zoomies klockan 6. Grannarna älskar oss säkert.",
        ],
        "p_olivia_1": [
            .english: "Foster pup found a forever home! Bittersweet happy tears today.",
            .french: "Le chiot en famille d'accueil a trouvé un foyer ! Larmes de joie aujourd'hui.",
            .swedish: "Foster-valpen hittade ett forever home! Söta tårar idag.",
        ],
        "p_olivia_2": [
            .english: "Shelter volunteer day — so many good boys still waiting for families.",
            .french: "Journée bénévole au refuge — tant de bons chiens attendent une famille.",
            .swedish: "Volontärdag på hägnet — så många bra hundar väntar fortfarande på familjer.",
        ],
        "p_leo_1": [
            .english: "Midnight city stroll. Streetlights, cool air, and a calm leash.",
            .french: "Balade nocturne en ville. Réverbères, air frais et laisse calme.",
            .swedish: "Midnatts-promenad i stan. Gatlyktor, sval luft och ett lugnt koppel.",
        ],
        "p_grace_1": [
            .english: "Puppy playdate chaos — ten pups, zero personal space, 100% joy.",
            .french: "Chaos de playdate — dix chiots, zéro espace perso, 100 % de joie.",
            .swedish: "Valpträff-kaos — tio valpar, noll personligt utrymme, 100 % glädje.",
        ],
        "p_grace_2": [
            .english: "Socialization tip: start with one calm buddy before the full party.",
            .french: "Conseil socialisation : commencez avec un copain calme avant la fête.",
            .swedish: "Socialiseringstips: börja med en lugn kompis innan hela gänget.",
        ],
        "p_noah_1": [
            .english: "First hike with Luna — she insisted on carrying her own backpack!",
            .french: "Première randonnée avec Luna — elle voulait porter son propre sac !",
            .swedish: "Första vandringen med Luna — hon ville bära sin egen ryggsäck!",
        ],
        "p_me_demo": [
            .english: "Sunday morning pack walk at Riverside Park — Biscuit made three new friends! Who else is bringing their pup next week?",
            .french: "Balade collective dimanche au parc Riverside — Biscuit a fait trois amis ! Qui amène son chien la semaine prochaine ?",
            .swedish: "Söndagsmorgon med grupppromenad i Riverside Park — Biscuit fick tre nya vänner! Vem tar med sin hund nästa vecka?",
        ],
    ]

    private static let postTimes: [String: [AppLanguage: String]] = [
        "p_emma_1": [.english: "5 hours ago", .french: "il y a 5 heures", .swedish: "för 5 timmar sedan"],
        "p_emma_2": [.english: "1 day ago", .french: "il y a 1 jour", .swedish: "för 1 dag sedan"],
        "p_james_1": [.english: "4 hours ago", .french: "il y a 4 heures", .swedish: "för 4 timmar sedan"],
        "p_sophie_1": [.english: "6 hours ago", .french: "il y a 6 heures", .swedish: "för 6 timmar sedan"],
        "p_sophie_2": [.english: "2 days ago", .french: "il y a 2 jours", .swedish: "för 2 dagar sedan"],
        "p_max_1": [.english: "3 hours ago", .french: "il y a 3 heures", .swedish: "för 3 timmar sedan"],
        "p_lily_1": [.english: "7 hours ago", .french: "il y a 7 heures", .swedish: "för 7 timmar sedan"],
        "p_lily_2": [.english: "1 day ago", .french: "il y a 1 jour", .swedish: "för 1 dag sedan"],
        "p_william_1": [.english: "8 hours ago", .french: "il y a 8 heures", .swedish: "för 8 timmar sedan"],
        "p_olivia_1": [.english: "9 hours ago", .french: "il y a 9 heures", .swedish: "för 9 timmar sedan"],
        "p_olivia_2": [.english: "3 days ago", .french: "il y a 3 jours", .swedish: "för 3 dagar sedan"],
        "p_leo_1": [.english: "11 hours ago", .french: "il y a 11 heures", .swedish: "för 11 timmar sedan"],
        "p_grace_1": [.english: "12 hours ago", .french: "il y a 12 heures", .swedish: "för 12 timmar sedan"],
        "p_grace_2": [.english: "2 days ago", .french: "il y a 2 jours", .swedish: "för 2 dagar sedan"],
        "p_noah_1": [.english: "1 day ago", .french: "il y a 1 jour", .swedish: "för 1 dag sedan"],
        "p_me_demo": [.english: "2 days ago", .french: "il y a 2 jours", .swedish: "för 2 dagar sedan"],
    ]
}

extension DemoContent {
    static func displayText(for activity: Activity) -> String {
        L10n.postBody(id: activity.id, fallback: activity.text)
    }

    static func displayTime(for activity: Activity) -> String {
        L10n.postTime(id: activity.id, fallback: activity.time)
    }
}
