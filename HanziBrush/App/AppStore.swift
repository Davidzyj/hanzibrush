import Foundation
import SwiftUI

@MainActor
final class AppStore: ObservableObject {
    @Published private(set) var selectedLanguage: AppLanguage?
    @Published private(set) var favoriteIDs: Set<String>
    @Published private(set) var practiceRecords: [String: PracticeRecord]
    @Published private(set) var artworks: [Artwork]
    @Published private(set) var streakDayKeys: Set<String>
    @Published var selectedTab: AppTab
    @Published var toastMessage: String?

    let characters = SeedData.characters
    let screenshotMode: Bool

    private let storage: LocalStorage
    private var toastTask: Task<Void, Never>?

    init() {
        let configuration = AppLaunchConfiguration.current
        screenshotMode = configuration.screenshotDemoData
        storage = LocalStorage(disabled: configuration.screenshotDemoData)

        let userData: UserData

        if configuration.screenshotDemoData {
            #if DEBUG
            userData = ScreenshotDemoDataProvider.userData()
            #else
            userData = .empty
            #endif
        } else {
            userData = storage.load()
        }

        selectedTab = configuration.initialTab
        selectedLanguage = userData.selectedLanguage
        favoriteIDs = Set(userData.favoriteIDs)
        practiceRecords = userData.practiceRecords
        artworks = userData.artworks
        streakDayKeys = Set(userData.streakDayKeys)
    }

    var language: AppLanguage {
        selectedLanguage ?? AppLanguage.inferred()
    }

    var dailyCharacter: HanziCharacter {
        let index = abs(Calendar.current.ordinality(of: .day, in: .era, for: Date()) ?? 0) % characters.count
        return characters[index]
    }

    var practicedCount: Int {
        practiceRecords.values.filter { $0.count > 0 }.count
    }

    var currentStreak: Int {
        var date = Date()
        var count = 0
        while streakDayKeys.contains(Self.dayKey(date)) {
            count += 1
            guard let previous = Calendar.current.date(byAdding: .day, value: -1, to: date) else { break }
            date = previous
        }
        return count
    }

    var recentPractices: [PracticeRecord] {
        practiceRecords.values
            .sorted { $0.lastPracticed > $1.lastPracticed }
            .prefix(4)
            .map { $0 }
    }

    func text(_ key: String) -> String {
        L10n.t(key, language)
    }

    func localizedName(for character: HanziCharacter) -> String {
        switch language {
        case .english:
            return character.english
        case .simplifiedChinese:
            return character.chinese
        case .japanese:
            return character.japanese
        }
    }

    func localizedStory(for character: HanziCharacter) -> String {
        switch language {
        case .english:
            return character.storyEN
        case .simplifiedChinese:
            return character.storyZH
        case .japanese:
            return character.storyJA
        }
    }

    func character(for id: String) -> HanziCharacter {
        characters.first(where: { $0.id == id }) ?? dailyCharacter
    }

    func isFavorite(_ id: String) -> Bool {
        favoriteIDs.contains(id)
    }

    func hasPracticedToday(_ id: String) -> Bool {
        practiceRecords[id]?.completedDayKeys.contains(Self.dayKey(Date())) == true
    }

    func setLanguage(_ language: AppLanguage?) {
        selectedLanguage = language
        save()
    }

    func toggleFavorite(_ id: String) {
        var copy = favoriteIDs
        if copy.contains(id) {
            copy.remove(id)
        } else {
            copy.insert(id)
        }
        favoriteIDs = copy
        save()
    }

    func savePractice(characterID: String, strokeCount: Int) {
        let now = Date()
        let key = Self.dayKey(now)
        var records = practiceRecords
        var record = records[characterID] ?? PracticeRecord(
            characterID: characterID,
            count: 0,
            lastPracticed: now,
            completedDayKeys: [],
            lastStrokeCount: 0
        )

        record.count += 1
        record.lastPracticed = now
        record.lastStrokeCount = strokeCount
        if !record.completedDayKeys.contains(key) {
            record.completedDayKeys.append(key)
        }
        records[characterID] = record
        practiceRecords = records

        var dayKeys = streakDayKeys
        dayKeys.insert(key)
        streakDayKeys = dayKeys

        save()
        showToast(text("practice.saved"))
    }

    func addArtwork(characterID: String, template: ArtworkTemplate, signature: String) {
        let artwork = Artwork(
            id: UUID(),
            characterID: characterID,
            template: template,
            signature: signature.trimmingCharacters(in: .whitespacesAndNewlines),
            createdAt: Date()
        )
        var copy = artworks
        copy.insert(artwork, at: 0)
        artworks = copy
        save()
        showToast(text("art.saved"))
    }

    func deleteArtwork(_ artwork: Artwork) {
        artworks = artworks.filter { $0.id != artwork.id }
        save()
        showToast(text("art.deleted"))
    }

    func clearLocalData() {
        selectedLanguage = nil
        favoriteIDs = []
        practiceRecords = [:]
        artworks = []
        streakDayKeys = []
        storage.clear()
        showToast(text("settings.cleared"))
    }

    func shareText(for artwork: Artwork) -> String {
        let character = character(for: artwork.characterID)
        let name = localizedName(for: character)
        let template = L10n.templateName(artwork.template, language)
        return "\(character.character) \(character.pinyin) - \(name)\nHanzi Brush · \(template)"
    }

    private func save() {
        let userData = UserData(
            selectedLanguage: selectedLanguage,
            favoriteIDs: Array(favoriteIDs).sorted(),
            practiceRecords: practiceRecords,
            artworks: artworks,
            streakDayKeys: Array(streakDayKeys).sorted()
        )
        storage.save(userData)
    }

    private func showToast(_ message: String) {
        toastTask?.cancel()
        toastMessage = message
        toastTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(2))
            await MainActor.run {
                self?.toastMessage = nil
            }
        }
    }

    nonisolated static func dayKey(_ date: Date) -> String {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", components.year ?? 0, components.month ?? 0, components.day ?? 0)
    }
}

struct AppLaunchConfiguration {
    let screenshotDemoData: Bool
    let initialTab: AppTab

    static var current: AppLaunchConfiguration {
        #if DEBUG
        let screenshotDemoData = CommandLine.arguments.contains("--screenshot-demo-data")
        return AppLaunchConfiguration(
            screenshotDemoData: screenshotDemoData,
            initialTab: screenshotDemoData ? Self.screenshotTabArgument() : .today
        )
        #else
        return AppLaunchConfiguration(screenshotDemoData: false, initialTab: .today)
        #endif
    }

    #if DEBUG
    private static func screenshotTabArgument() -> AppTab {
        guard let index = CommandLine.arguments.firstIndex(of: "--screenshot-tab"),
              CommandLine.arguments.indices.contains(index + 1),
              let tab = AppTab(rawValue: CommandLine.arguments[index + 1]) else {
            return .today
        }
        return tab
    }
    #endif
}

struct LocalStorage {
    let disabled: Bool

    private var fileURL: URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return base
            .appendingPathComponent("HanziBrush", isDirectory: true)
            .appendingPathComponent("user-data.json")
    }

    func load() -> UserData {
        guard !disabled else { return .empty }
        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder.appDecoder.decode(UserData.self, from: data)
        } catch {
            return .empty
        }
    }

    func save(_ data: UserData) {
        guard !disabled else { return }
        do {
            let directory = fileURL.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
            let encoded = try JSONEncoder.appEncoder.encode(data)
            try encoded.write(to: fileURL, options: [.atomic])
        } catch {
            assertionFailure("Failed to save local data: \(error)")
        }
    }

    func clear() {
        guard !disabled else { return }
        try? FileManager.default.removeItem(at: fileURL)
    }
}

extension JSONEncoder {
    static var appEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }
}

extension JSONDecoder {
    static var appDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}

#if DEBUG
enum ScreenshotDemoDataProvider {
    static func userData() -> UserData {
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today) ?? today
        let twoDays = Calendar.current.date(byAdding: .day, value: -2, to: today) ?? today
        let todayKey = AppStore.dayKey(today)
        let yesterdayKey = AppStore.dayKey(yesterday)
        let twoDaysKey = AppStore.dayKey(twoDays)

        return UserData(
            selectedLanguage: .english,
            favoriteIDs: ["fu", "dao", "ai", "cha"],
            practiceRecords: [
                "fu": PracticeRecord(characterID: "fu", count: 4, lastPracticed: today, completedDayKeys: [todayKey], lastStrokeCount: 8),
                "dao": PracticeRecord(characterID: "dao", count: 3, lastPracticed: yesterday, completedDayKeys: [yesterdayKey], lastStrokeCount: 7),
                "chun": PracticeRecord(characterID: "chun", count: 2, lastPracticed: twoDays, completedDayKeys: [twoDaysKey], lastStrokeCount: 6)
            ],
            artworks: [
                Artwork(id: UUID(uuidString: "D57A52D5-5325-4753-B2C8-0E0E5B55A101")!, characterID: "chun", template: .festival, signature: "Jay", createdAt: today),
                Artwork(id: UUID(uuidString: "CA0F8E11-918E-42BE-898B-61E6DD7C4402")!, characterID: "fu", template: .ricePaper, signature: "Hanzi Brush", createdAt: yesterday)
            ],
            streakDayKeys: [todayKey, yesterdayKey, twoDaysKey]
        )
    }
}
#endif
