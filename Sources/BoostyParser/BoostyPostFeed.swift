import Foundation
import Common

// MARK: - BoostyPostFeed
struct BoostyPostFeed: Decodable {
    let data: [BoostyPost]
    let extra: BoostyPostFeedExtra
}

// MARK: - BoostyPostFeedDatum
struct BoostyPost: Decodable {
    let isPublished, hasAccess: Bool
    let id: String
    let isCommentsDenied: Bool
    let price: Int
    let subscriptionLevel: SubscriptionLevel?
    let isWaitingVideo, isLiked: Bool
    let publishTime: Int
    let tags: [Tag]
    let count: Count
    let donators: Donators
    let isBlocked, isDeleted: Bool
    let updatedAt: Int
    let comments: Comments
    let donations: Int
    let isRecord: Bool
    let teaser: [TeaserElement]
    let user: User
    let createdAt: Int
    let signedQuery: String
    let contentCounters: [ContentCounter]
    let showViewsCounter: Bool
    let title: String
    let currencyPrices: [String: Double]
    let data: [TeaserElement]

    enum CodingKeys: String, CodingKey {
        case isPublished, hasAccess, id, isCommentsDenied, price, subscriptionLevel, isWaitingVideo, isLiked, publishTime, tags, count, donators, isBlocked, isDeleted, updatedAt, comments, donations, isRecord, teaser
        case user, createdAt, signedQuery, contentCounters, showViewsCounter, title, currencyPrices, data
    }
}

// MARK: - CommentsDatum
struct CommentsDatum: Decodable {
    let reactions: Reactions
    let createdAt: Int
    let replies: Comments
    let isBlocked, isUpdated: Bool
    let data: [PurpleDatum]
    let isDeleted: Bool
    let replyCount: Int
    let id: String
    let author: Author
    let post: Post

    enum CodingKeys: String, CodingKey {
        case reactions, createdAt, replies, isBlocked, isUpdated, data, isDeleted, replyCount, id
        case author, post
    }
}

// MARK: - Comments
struct Comments: Decodable {
    let data: [CommentsDatum]
    let extra: CommentsExtra
}

// MARK: - Author
struct Author: Decodable {
    let hasAvatar: Bool
    let id: Int
    let name: String
    let avatarURL: String

    enum CodingKeys: String, CodingKey {
        case hasAvatar, id, name
        case avatarURL = "avatarUrl"
    }
}

// MARK: - PurpleDatum
struct PurpleDatum: Decodable {
    let content: String
    let modificator: Modificator
    @Optionally var type: TypeEnum?
}

enum Modificator: String, Decodable {
    case blockEnd = "BLOCK_END"
    case empty = ""
}

enum TypeEnum: String, Decodable {
    case image = "image"
    case text = "text"
}

// MARK: - Post
struct Post: Decodable {
    let id: String
}

// MARK: - Reactions
struct Reactions: Decodable {
    let like, dislike, fire, sad: Int
    let heart, angry, laught, wonder: Int
}

// MARK: - CommentsExtra
struct CommentsExtra: Decodable {
    let isFirst: Bool?
    let isLast: Bool?
}

// MARK: - ContentCounter
struct ContentCounter: Decodable {
    let count: Int
    @Optionally var type: TypeEnum?
    let size: Int
}

// MARK: - Count
struct Count: Decodable {
    let comments, likes: Int
    let reactions: Reactions
}

// MARK: - TeaserElement
struct TeaserElement: Decodable {
    let url: URL?
    let size, height: Int?
    let id: String?
    @Optionally var rendition: Rendition?
    let width: Int?
    @Optionally var type: TypeEnum?
    @Optionally var modificator: Modificator?
    let content: String?
}

enum Rendition: String, Decodable {
    case empty = ""
    case teaserAutoBackground = "teaser_auto_background"
}

// MARK: - Donators
struct Donators: Decodable {
    let extra: DonatorsExtra
}

// MARK: - DonatorsExtra
struct DonatorsExtra: Decodable {
    let isLast: Bool
}

// MARK: - SubscriptionLevel
struct SubscriptionLevel: Decodable {
    let data: [TeaserElement]
    let isArchived: Bool
    let ownerID: Int
    let currencyPrices: [String: Double]
    let price, id: Int
    let name: String
    let deleted: Bool
    let createdAt: Int

    enum CodingKeys: String, CodingKey {
        case data, isArchived
        case ownerID = "ownerId"
        case currencyPrices, price, id, name, deleted, createdAt
    }
}

// MARK: - Tag
struct Tag: Decodable {
    let title: String
    let id: Int
}

// MARK: - User
struct User: Decodable {
    let hasAvatar: Bool
    let name: String
    let id: Int
    let blogURL: String
    let avatarURL: String
    let flags: Flags

    enum CodingKeys: String, CodingKey {
        case hasAvatar, name, id
        case blogURL = "blogUrl"
        case avatarURL = "avatarUrl"
        case flags
    }
}

// MARK: - Flags
struct Flags: Decodable {
    let showPostDonations: Bool
}

// MARK: - BoostyPostFeedExtra
struct BoostyPostFeedExtra: Decodable {
    let offset: String
    let isLast: Bool
}
