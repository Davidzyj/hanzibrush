import Foundation
import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case today
    case practice
    case artworks
    case library
    case settings

    var id: String { rawValue }
}

enum AppLanguage: String, CaseIterable, Identifiable, Codable {
    case english = "en"
    case simplifiedChinese = "zh-Hans"
    case japanese = "ja"

    var id: String { rawValue }

    static func inferred() -> AppLanguage {
        let preferred = Locale.preferredLanguages.first?.lowercased() ?? ""
        let region = Locale.current.region?.identifier.lowercased() ?? ""

        if preferred.hasPrefix("ja") || region == "jp" {
            return .japanese
        }

        if preferred.hasPrefix("zh") || ["cn", "sg", "hk", "mo", "tw"].contains(region) {
            return .simplifiedChinese
        }

        return .english
    }
}

enum HanziTheme: String, CaseIterable, Identifiable, Codable {
    case blessing
    case nature
    case feeling
    case season
    case wisdom

    var id: String { rawValue }
}

struct HanziCharacter: Identifiable, Codable, Equatable {
    let id: String
    let character: String
    let pinyin: String
    let english: String
    let chinese: String
    let japanese: String
    let storyEN: String
    let storyZH: String
    let storyJA: String
    let radical: String
    let strokeCount: Int
    let theme: HanziTheme
    let free: Bool
    let strokeHints: [String]
}

struct PracticeRecord: Codable, Equatable {
    var characterID: String
    var count: Int
    var lastPracticed: Date
    var completedDayKeys: [String]
    var lastStrokeCount: Int
}

struct Artwork: Identifiable, Codable, Equatable {
    var id: UUID
    var characterID: String
    var template: ArtworkTemplate
    var signature: String
    var createdAt: Date
}

enum ArtworkTemplate: String, CaseIterable, Identifiable, Codable {
    case ricePaper
    case cinnabar
    case jade
    case festival

    var id: String { rawValue }
}

struct UserData: Codable, Equatable {
    var selectedLanguage: AppLanguage?
    var favoriteIDs: [String]
    var practiceRecords: [String: PracticeRecord]
    var artworks: [Artwork]
    var streakDayKeys: [String]

    static let empty = UserData(
        selectedLanguage: nil,
        favoriteIDs: [],
        practiceRecords: [:],
        artworks: [],
        streakDayKeys: []
    )
}

struct BrushLine: Identifiable, Equatable {
    let id = UUID()
    var points: [CGPoint]
}

enum SeedData {
    static let characters: [HanziCharacter] = [
        HanziCharacter(
            id: "fu",
            character: "福",
            pinyin: "fu",
            english: "Blessing",
            chinese: "福气与祝愿",
            japanese: "幸福と祝福",
            storyEN: "A character often seen during Lunar New Year. It carries a wish for good fortune, warmth, and family joy.",
            storyZH: "常见于春节与新年祝福，代表好运、家人团圆和对未来的善意期待。",
            storyJA: "春節によく見られる字で、幸運、家族の団らん、未来への願いを表します。",
            radical: "礻",
            strokeCount: 13,
            theme: .blessing,
            free: true,
            strokeHints: ["丶", "フ", "丨", "丶", "一", "口", "田"]
        ),
        HanziCharacter(
            id: "dao",
            character: "道",
            pinyin: "dao",
            english: "The Way",
            chinese: "道路、方法与方向",
            japanese: "道、方法、方向",
            storyEN: "Dao can mean a road, a method, or a guiding principle. It is compact, philosophical, and memorable.",
            storyZH: "道既可以表示道路，也可以表示方法、原则和人生方向。",
            storyJA: "道は道路、方法、原則、生き方の方向を表すことがあります。",
            radical: "辶",
            strokeCount: 12,
            theme: .wisdom,
            free: true,
            strokeHints: ["丶", "丿", "一", "丿", "丨", "フ", "一", "一", "一", "丶", "フ", "㇏"]
        ),
        HanziCharacter(
            id: "chun",
            character: "春",
            pinyin: "chun",
            english: "Spring",
            chinese: "新生与节日",
            japanese: "春、新しい始まり",
            storyEN: "Spring suggests renewal and festival greetings. It is a friendly character for cards and wallpapers.",
            storyZH: "春代表新生、温暖和节日气息，很适合制作贺卡与壁纸。",
            storyJA: "春は新しい始まり、あたたかさ、祝いの雰囲気を感じさせます。",
            radical: "日",
            strokeCount: 9,
            theme: .season,
            free: true,
            strokeHints: ["一", "一", "一", "丿", "㇏", "丨", "フ", "一", "一"]
        ),
        HanziCharacter(
            id: "ai",
            character: "爱",
            pinyin: "ai",
            english: "Love",
            chinese: "亲情与爱意",
            japanese: "愛",
            storyEN: "A modern simplified character for love. It works well for personal notes and keepsakes.",
            storyZH: "爱表达亲情、友情和珍惜，是适合个人卡片与纪念作品的汉字。",
            storyJA: "愛は大切に思う気持ちを表し、個人的なカードにも向いています。",
            radical: "爫",
            strokeCount: 10,
            theme: .feeling,
            free: true,
            strokeHints: ["丿", "丶", "丶", "丿", "丶", "フ", "一", "丿", "フ", "㇏"]
        ),
        HanziCharacter(
            id: "an",
            character: "安",
            pinyin: "an",
            english: "Peace",
            chinese: "安定与平静",
            japanese: "安らぎ",
            storyEN: "An is calm and balanced. It can mean peaceful, safe, or settled.",
            storyZH: "安给人平静、安稳和安心的感觉，是一个很适合日常练习的字。",
            storyJA: "安は穏やかさ、安全、落ち着きを感じさせる字です。",
            radical: "宀",
            strokeCount: 6,
            theme: .blessing,
            free: true,
            strokeHints: ["丶", "丶", "フ", "フ", "丿", "一"]
        ),
        HanziCharacter(
            id: "xi",
            character: "喜",
            pinyin: "xi",
            english: "Joy",
            chinese: "喜悦与庆祝",
            japanese: "喜び",
            storyEN: "A bright character for celebrations, weddings, and happy news.",
            storyZH: "喜代表喜悦、庆祝和好消息，在节日与婚礼中很常见。",
            storyJA: "喜は喜びや祝いを表し、めでたい場面でよく使われます。",
            radical: "口",
            strokeCount: 12,
            theme: .blessing,
            free: true,
            strokeHints: ["一", "丨", "一", "丨", "フ", "一", "丶", "丿", "一", "丨", "フ", "一"]
        ),
        HanziCharacter(
            id: "cha",
            character: "茶",
            pinyin: "cha",
            english: "Tea",
            chinese: "茶与待客之道",
            japanese: "茶",
            storyEN: "Tea connects daily life, hospitality, and quiet focus.",
            storyZH: "茶连接日常生活、待客之道和安静专注的时刻。",
            storyJA: "茶は日常、もてなし、静かな集中の時間と結びつきます。",
            radical: "艹",
            strokeCount: 9,
            theme: .nature,
            free: true,
            strokeHints: ["一", "丨", "丨", "丿", "㇏", "一", "丨", "丿", "丶"]
        ),
        HanziCharacter(
            id: "yue",
            character: "月",
            pinyin: "yue",
            english: "Moon",
            chinese: "月亮与团圆",
            japanese: "月",
            storyEN: "The moon often carries reunion, poetry, and festival imagery.",
            storyZH: "月常与团圆、诗意和节日意象联系在一起。",
            storyJA: "月は団らん、詩情、祭りのイメージと結びつきます。",
            radical: "月",
            strokeCount: 4,
            theme: .nature,
            free: true,
            strokeHints: ["丿", "フ", "一", "一"]
        ),
        HanziCharacter(
            id: "shan",
            character: "山",
            pinyin: "shan",
            english: "Mountain",
            chinese: "山与稳定",
            japanese: "山",
            storyEN: "A simple and powerful shape. It is one of the most approachable characters for beginners.",
            storyZH: "山的字形简单有力，是初学者很容易建立信心的汉字。",
            storyJA: "山は形が分かりやすく、初心者にも親しみやすい字です。",
            radical: "山",
            strokeCount: 3,
            theme: .nature,
            free: false,
            strokeHints: ["丨", "フ", "丨"]
        ),
        HanziCharacter(
            id: "xin",
            character: "心",
            pinyin: "xin",
            english: "Heart",
            chinese: "心意与感受",
            japanese: "心",
            storyEN: "Heart is compact, expressive, and useful for many cultural phrases.",
            storyZH: "心表达心意、感受和精神，是很多词语里的核心部件。",
            storyJA: "心は気持ちや精神を表し、多くの言葉に使われます。",
            radical: "心",
            strokeCount: 4,
            theme: .feeling,
            free: false,
            strokeHints: ["丶", "フ", "丶", "丶"]
        ),
        HanziCharacter(
            id: "ming",
            character: "明",
            pinyin: "ming",
            english: "Bright",
            chinese: "光明与理解",
            japanese: "明るさ",
            storyEN: "Sun and moon together suggest brightness, clarity, and understanding.",
            storyZH: "日月相合成明，带来光亮、清晰和理解的意味。",
            storyJA: "日と月が合わさり、明るさ、明晰さ、理解を表します。",
            radical: "日",
            strokeCount: 8,
            theme: .wisdom,
            free: false,
            strokeHints: ["丨", "フ", "一", "一", "丿", "フ", "一", "一"]
        ),
        HanziCharacter(
            id: "he",
            character: "和",
            pinyin: "he",
            english: "Harmony",
            chinese: "和谐与相处",
            japanese: "調和",
            storyEN: "Harmony is a warm character for relationships, food, and balanced living.",
            storyZH: "和代表和谐、相处与平衡，也常出现在饮食与生活语境中。",
            storyJA: "和は調和、関係、穏やかな暮らしを感じさせます。",
            radical: "口",
            strokeCount: 8,
            theme: .wisdom,
            free: false,
            strokeHints: ["丿", "一", "丨", "丿", "丶", "丨", "フ", "一"]
        )
    ]

    static func character(id: String) -> HanziCharacter {
        characters.first(where: { $0.id == id }) ?? characters[0]
    }
}
