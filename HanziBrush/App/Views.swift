import SwiftUI
import UIKit

struct RootView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        ZStack(alignment: .bottom) {
            PaperBackground()

            TabView(selection: $store.selectedTab) {
                TodayView()
                    .tag(AppTab.today)
                    .tabItem { Label(store.text("tab.today"), systemImage: "sun.max.fill") }

                PracticeEntryView()
                    .tag(AppTab.practice)
                    .tabItem { Label(store.text("tab.practice"), systemImage: "paintbrush.pointed.fill") }

                ArtworkStudioView()
                    .tag(AppTab.artworks)
                    .tabItem { Label(store.text("tab.artworks"), systemImage: "square.on.square.fill") }

                LibraryView()
                    .tag(AppTab.library)
                    .tabItem { Label(store.text("tab.library"), systemImage: "books.vertical.fill") }

                SettingsView()
                    .tag(AppTab.settings)
                    .tabItem { Label(store.text("tab.settings"), systemImage: "gearshape.fill") }
            }
            .scrollContentBackground(.hidden)

            if let toast = store.toastMessage {
                ToastView(message: toast)
                    .padding(.bottom, 62)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.28, dampingFraction: 0.9), value: store.toastMessage)
    }
}

struct TodayView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    HeaderView(eyebrow: store.text("today.eyebrow"), title: store.text("today.title"))

                    DailyCard(character: store.dailyCharacter)

                    HStack(spacing: 10) {
                        StatCard(value: "\(store.currentStreak)", label: store.text("today.streak"))
                        StatCard(value: "\(store.practicedCount)", label: store.text("today.practiced"))
                        StatCard(value: "\(store.artworks.count)", label: store.text("today.artworks"))
                    }

                    SectionTitle(title: store.text("today.continue"))

                    if store.recentPractices.isEmpty {
                        EmptyState(text: store.text("today.empty"))
                    } else {
                        VStack(spacing: 10) {
                            ForEach(store.recentPractices, id: \.characterID) { record in
                                NavigationLink {
                                    CharacterDetailView(character: store.character(for: record.characterID))
                                } label: {
                                    PracticeRow(record: record)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(18)
                .padding(.bottom, 16)
            }
            .background(PaperBackground())
            .navigationBarHidden(true)
        }
    }
}

struct DailyCard: View {
    @EnvironmentObject private var store: AppStore
    let character: HanziCharacter

    var body: some View {
        PaperCard {
            HStack(alignment: .center, spacing: 16) {
                HanziTile(character: character.character, size: 138)

                VStack(alignment: .leading, spacing: 8) {
                    Text("\(character.pinyin) / \(store.localizedName(for: character))")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(InkTheme.teal)
                        .lineLimit(2)

                    Text(character.character)
                        .font(.system(size: 30, weight: .heavy))
                        .foregroundStyle(InkTheme.ink)

                    Text(store.localizedStory(for: character))
                        .font(.system(size: 14))
                        .foregroundStyle(InkTheme.ink2)
                        .lineLimit(4)

                    HStack(spacing: 8) {
                        NavigationLink {
                            PracticeView(character: character)
                        } label: {
                            Text(store.hasPracticedToday(character.id) ? store.text("today.practiceAgain") : store.text("today.start"))
                        }
                        .buttonStyle(PrimaryButtonStyle())

                        Button {
                            store.toggleFavorite(character.id)
                        } label: {
                            Image(systemName: store.isFavorite(character.id) ? "heart.fill" : "heart")
                                .accessibilityLabel(store.isFavorite(character.id) ? store.text("today.unfavorite") : store.text("today.favorite"))
                        }
                        .buttonStyle(IconButtonStyle(active: store.isFavorite(character.id)))
                    }
                }
            }

            if store.hasPracticedToday(character.id) {
                StatusPill(text: store.text("today.completed"), systemImage: "checkmark.seal.fill")
                    .padding(.top, 12)
            }
        }
    }
}

struct PracticeEntryView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HeaderView(eyebrow: store.text("practice.eyebrow"), title: store.text("detail.title"))

                    ForEach(store.characters) { character in
                        NavigationLink {
                            CharacterDetailView(character: character)
                        } label: {
                            CharacterListRow(character: character)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(18)
            }
            .background(PaperBackground())
            .navigationBarHidden(true)
        }
    }
}

struct CharacterDetailView: View {
    @EnvironmentObject private var store: AppStore
    let character: HanziCharacter

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HeaderView(eyebrow: store.text("detail.eyebrow"), title: store.text("detail.title"))

                PaperCard {
                    HStack(alignment: .center, spacing: 16) {
                        HanziTile(character: character.character, size: 142)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("\(character.pinyin) / \(store.localizedName(for: character))")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(InkTheme.teal)
                            Text(character.character)
                                .font(.system(size: 32, weight: .heavy))
                                .foregroundStyle(InkTheme.ink)
                            Text(store.localizedStory(for: character))
                                .font(.system(size: 14))
                                .foregroundStyle(InkTheme.ink2)
                        }
                    }
                }

                HStack(spacing: 10) {
                    InfoBox(label: store.text("detail.radical"), value: character.radical)
                    InfoBox(label: store.text("detail.strokes"), value: "\(character.strokeCount)")
                    InfoBox(label: store.text("detail.theme"), value: L10n.themeName(character.theme, store.language))
                }

                PaperCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(store.text("detail.story"))
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(InkTheme.ink)
                        Text(store.localizedStory(for: character))
                            .font(.system(size: 15))
                            .foregroundStyle(InkTheme.ink2)
                    }
                }

                SectionTitle(title: store.text("detail.strokePreview"))

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
                    ForEach(Array(character.strokeHints.enumerated()), id: \.offset) { index, hint in
                        StrokeHintCell(index: index + 1, hint: hint)
                    }
                }

                HStack(spacing: 10) {
                    NavigationLink {
                        PracticeView(character: character)
                    } label: {
                        Text(store.text("today.start"))
                    }
                    .buttonStyle(PrimaryButtonStyle())

                    NavigationLink {
                        ArtworkStudioView(preselectedCharacterID: character.id)
                    } label: {
                        Text(store.text("detail.generate"))
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }

                Button {
                    store.toggleFavorite(character.id)
                } label: {
                    Label(store.isFavorite(character.id) ? store.text("today.unfavorite") : store.text("today.favorite"), systemImage: store.isFavorite(character.id) ? "heart.fill" : "heart")
                }
                .buttonStyle(SecondaryButtonStyle())
            }
            .padding(18)
            .padding(.bottom, 24)
        }
        .background(PaperBackground())
        .navigationTitle(character.character)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PracticeView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    let character: HanziCharacter
    @State private var lines: [BrushLine] = []
    @State private var showGuides = true
    @State private var showGhost = true

    var body: some View {
        VStack(spacing: 14) {
            HeaderView(eyebrow: store.text("practice.eyebrow"), title: "\(store.text("today.start")) \(character.character)")
                .padding(.horizontal, 18)

            DrawingBoard(character: character.character, lines: $lines, showGuides: showGuides, showGhost: showGhost)
                .frame(height: 360)
                .padding(.horizontal, 18)

            Text("\(store.text("practice.progress")): \(lines.count)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(InkTheme.ink2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 18)

            HStack(spacing: 8) {
                ToolButton(title: store.text("practice.undo"), systemImage: "arrow.uturn.backward") {
                    if !lines.isEmpty {
                        lines.removeLast()
                    }
                }
                ToolButton(title: store.text("practice.clear"), systemImage: "trash") {
                    lines = []
                }
                ToolButton(title: store.text("practice.guides"), systemImage: "grid") {
                    showGuides.toggle()
                }
                ToolButton(title: store.text("practice.compare"), systemImage: "eye") {
                    showGhost.toggle()
                }
            }
            .padding(.horizontal, 18)

            HStack(spacing: 10) {
                Button {
                    store.savePractice(characterID: character.id, strokeCount: lines.count)
                    dismiss()
                } label: {
                    Text(lines.isEmpty ? store.text("practice.disabled") : store.text("practice.save"))
                }
                .disabled(lines.isEmpty)
                .buttonStyle(PrimaryButtonStyle(disabled: lines.isEmpty))

                Button {
                    dismiss()
                } label: {
                    Text(store.text("common.back"))
                }
                .buttonStyle(SecondaryButtonStyle())
            }
            .padding(.horizontal, 18)

            Spacer()
        }
        .padding(.top, 18)
        .background(PaperBackground())
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DrawingBoard: View {
    let character: String
    @Binding var lines: [BrushLine]
    let showGuides: Bool
    let showGhost: Bool
    @State private var currentLine: BrushLine?

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(InkTheme.paperStrong)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(InkTheme.line, lineWidth: 1))

                if showGuides {
                    TianGrid()
                        .stroke(InkTheme.red.opacity(0.24), style: StrokeStyle(lineWidth: 1, dash: [5, 5]))
                        .padding(18)
                }

                if showGhost {
                    Text(character)
                        .font(.system(size: min(proxy.size.width, proxy.size.height) * 0.62, weight: .heavy, design: .serif))
                        .foregroundStyle(InkTheme.ink.opacity(0.13))
                }

                Canvas { context, _ in
                    for line in lines {
                        draw(line, context: &context)
                    }
                    if let currentLine {
                        draw(currentLine, context: &context)
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if currentLine == nil {
                            currentLine = BrushLine(points: [value.location])
                        } else {
                            currentLine?.points.append(value.location)
                        }
                    }
                    .onEnded { _ in
                        if let currentLine, currentLine.points.count > 1 {
                            lines.append(currentLine)
                        }
                        currentLine = nil
                    }
            )
        }
    }

    private func draw(_ line: BrushLine, context: inout GraphicsContext) {
        guard let first = line.points.first else { return }
        var path = Path()
        path.move(to: first)
        for point in line.points.dropFirst() {
            path.addLine(to: point)
        }
        context.stroke(path, with: .color(InkTheme.ink.opacity(0.88)), style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round))
    }
}

struct ArtworkStudioView: View {
    @EnvironmentObject private var store: AppStore
    @FocusState private var focusedField: Field?
    @State private var selectedCharacterID: String
    @State private var selectedTemplate: ArtworkTemplate = .ricePaper
    @State private var signature = ""
    @State private var shareArtwork: Artwork?

    enum Field {
        case signature
    }

    init(preselectedCharacterID: String? = nil) {
        _selectedCharacterID = State(initialValue: preselectedCharacterID ?? SeedData.characters[0].id)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HeaderView(eyebrow: store.text("art.eyebrow"), title: store.text("art.title"))

                    ArtworkPreview(character: store.character(for: selectedCharacterID), template: selectedTemplate, signature: signature)

                    Picker(store.text("art.choose"), selection: $selectedCharacterID) {
                        ForEach(store.characters) { character in
                            Text("\(character.character) \(character.pinyin)").tag(character.id)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(InkTheme.red)

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
                        ForEach(ArtworkTemplate.allCases) { template in
                            Button {
                                selectedTemplate = template
                            } label: {
                                TemplateCell(template: template, selected: selectedTemplate == template)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text(store.text("art.signature"))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(InkTheme.ink)
                        TextField(store.text("art.signaturePlaceholder"), text: $signature)
                            .textInputAutocapitalization(.words)
                            .submitLabel(.done)
                            .focused($focusedField, equals: .signature)
                            .onSubmit { focusedField = nil }
                            .padding(12)
                            .foregroundStyle(InkTheme.ink)
                            .background(InkTheme.paperStrong)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(InkTheme.line, lineWidth: 1))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    Button {
                        focusedField = nil
                        store.addArtwork(characterID: selectedCharacterID, template: selectedTemplate, signature: signature)
                    } label: {
                        Text(store.text("art.create"))
                    }
                    .buttonStyle(PrimaryButtonStyle())

                    SectionTitle(title: store.text("tab.artworks"))

                    if store.artworks.isEmpty {
                        EmptyState(text: store.text("art.empty"))
                    } else {
                        VStack(spacing: 10) {
                            ForEach(store.artworks) { artwork in
                                ArtworkRow(artwork: artwork, onShare: {
                                    focusedField = nil
                                    shareArtwork = artwork
                                })
                            }
                        }
                    }
                }
                .padding(18)
                .padding(.bottom, 20)
            }
            .background(PaperBackground())
            .navigationBarHidden(true)
            .scrollDismissesKeyboard(.interactively)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button(store.text("common.done")) {
                        focusedField = nil
                    }
                    .foregroundStyle(InkTheme.red)
                }
            }
            .sheet(item: $shareArtwork) { artwork in
                ShareSheet(items: [store.shareText(for: artwork)])
            }
        }
    }
}

struct LibraryView: View {
    @EnvironmentObject private var store: AppStore
    @FocusState private var searchFocused: Bool
    @State private var searchText = ""
    @State private var selectedTheme: HanziTheme?
    @State private var favoritesOnly = false

    var filteredCharacters: [HanziCharacter] {
        store.characters.filter { character in
            if favoritesOnly && !store.isFavorite(character.id) {
                return false
            }
            if let selectedTheme, character.theme != selectedTheme {
                return false
            }
            let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            guard !query.isEmpty else { return true }
            return character.character.contains(query)
                || character.pinyin.localizedCaseInsensitiveContains(query)
                || character.english.localizedCaseInsensitiveContains(query)
                || character.chinese.localizedCaseInsensitiveContains(query)
                || character.japanese.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    HeaderView(eyebrow: store.text("library.eyebrow"), title: store.text("library.title"))

                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(InkTheme.ink3)
                        TextField(store.text("library.search"), text: $searchText)
                            .foregroundStyle(InkTheme.ink)
                            .focused($searchFocused)
                            .submitLabel(.done)
                            .onSubmit { searchFocused = false }
                    }
                    .padding(12)
                    .background(InkTheme.paperStrong)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(InkTheme.line, lineWidth: 1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChip(title: store.text("library.all"), selected: !favoritesOnly && selectedTheme == nil) {
                                favoritesOnly = false
                                selectedTheme = nil
                            }
                            FilterChip(title: store.text("library.favorites"), selected: favoritesOnly) {
                                favoritesOnly.toggle()
                            }
                            ForEach(HanziTheme.allCases) { theme in
                                FilterChip(title: L10n.themeName(theme, store.language), selected: selectedTheme == theme) {
                                    selectedTheme = selectedTheme == theme ? nil : theme
                                }
                            }
                        }
                    }

                    if filteredCharacters.isEmpty {
                        EmptyState(text: store.text("library.noResults"))
                        Button {
                            searchText = ""
                            selectedTheme = nil
                            favoritesOnly = false
                            searchFocused = false
                        } label: {
                            Text(store.text("library.showAll"))
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    } else {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 2), spacing: 10) {
                            ForEach(filteredCharacters) { character in
                                NavigationLink {
                                    CharacterDetailView(character: character)
                                } label: {
                                    CharacterGridCard(character: character)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(18)
                .padding(.bottom, 20)
            }
            .background(PaperBackground())
            .navigationBarHidden(true)
            .scrollDismissesKeyboard(.interactively)
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject private var store: AppStore
    @State private var showClearConfirmation = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HeaderView(eyebrow: store.text("settings.eyebrow"), title: store.text("settings.title"))

                    PaperCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(store.text("settings.language"))
                                .font(.system(size: 17, weight: .bold))
                                .foregroundStyle(InkTheme.ink)
                            Text(store.text("settings.systemHint"))
                                .font(.system(size: 13))
                                .foregroundStyle(InkTheme.ink3)

                            ForEach(AppLanguage.allCases) { language in
                                Button {
                                    store.setLanguage(language)
                                } label: {
                                    HStack {
                                        Text(L10n.languageName(language, current: store.language))
                                            .foregroundStyle(InkTheme.ink)
                                        Spacer()
                                        if store.selectedLanguage == language {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(InkTheme.teal)
                                        }
                                    }
                                    .padding(12)
                                    .background(InkTheme.paper)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    SettingsLinkRow(systemImage: "lock.shield.fill", title: store.text("settings.privacy"), subtitle: "davidzyj.github.io/hanzibrush/privacy") {
                        openURL("https://davidzyj.github.io/hanzibrush/privacy/")
                    }

                    SettingsLinkRow(systemImage: "questionmark.circle.fill", title: store.text("settings.support"), subtitle: "davidzyj.github.io/hanzibrush/support") {
                        openURL("https://davidzyj.github.io/hanzibrush/support/")
                    }

                    SettingsLinkRow(systemImage: "envelope.fill", title: store.text("settings.email"), subtitle: "jay212315@gmail.com") {
                        openURL("mailto:jay212315@gmail.com?subject=Hanzi%20Brush%20Support")
                    }

                    PaperCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(store.text("settings.data"))
                                .font(.system(size: 17, weight: .bold))
                                .foregroundStyle(InkTheme.ink)
                            Text(store.text("settings.paid"))
                                .font(.system(size: 13))
                                .foregroundStyle(InkTheme.ink3)
                            Button(role: .destructive) {
                                showClearConfirmation = true
                            } label: {
                                Text(store.text("settings.clearData"))
                            }
                            .buttonStyle(SecondaryButtonStyle())
                        }
                    }

                    Text(store.text("settings.version"))
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(InkTheme.ink3)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 8)
                }
                .padding(18)
                .padding(.bottom, 22)
            }
            .background(PaperBackground())
            .navigationBarHidden(true)
            .confirmationDialog(store.text("settings.clearData"), isPresented: $showClearConfirmation, titleVisibility: .visible) {
                Button(store.text("settings.clearConfirm"), role: .destructive) {
                    store.clearLocalData()
                }
                Button(store.text("common.cancel"), role: .cancel) {}
            }
        }
    }

    private func openURL(_ value: String) {
        guard let url = URL(string: value) else { return }
        UIApplication.shared.open(url)
    }
}

struct HeaderView: View {
    let eyebrow: String
    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(eyebrow.uppercased())
                .font(.system(size: 12, weight: .heavy))
                .foregroundStyle(InkTheme.redDeep)
            Text(title)
                .font(.system(size: 30, weight: .heavy))
                .foregroundStyle(InkTheme.ink)
                .lineLimit(2)
                .minimumScaleFactor(0.82)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct HanziTile: View {
    let character: String
    let size: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(InkTheme.paperStrong)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(InkTheme.line, lineWidth: 1))

            TianGrid()
                .stroke(InkTheme.red.opacity(0.25), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                .padding(12)

            Text(character)
                .font(.system(size: size * 0.58, weight: .heavy, design: .serif))
                .foregroundStyle(InkTheme.ink)
        }
        .frame(width: size, height: size)
    }
}

struct TianGrid: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addRect(rect)
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        return path
    }
}

struct StatCard: View {
    let value: String
    let label: String

    var body: some View {
        PaperCard(padding: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(value)
                    .font(.system(size: 25, weight: .heavy))
                    .foregroundStyle(InkTheme.ink)
                Text(label)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(InkTheme.ink3)
                    .lineLimit(2)
                    .minimumScaleFactor(0.78)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct SectionTitle: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 18, weight: .bold))
            .foregroundStyle(InkTheme.ink)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct EmptyState: View {
    let text: String

    var body: some View {
        PaperCard {
            Text(text)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(InkTheme.ink2)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct PracticeRow: View {
    @EnvironmentObject private var store: AppStore
    let record: PracticeRecord

    var body: some View {
        let character = store.character(for: record.characterID)
        PaperCard(padding: 12) {
            HStack(spacing: 12) {
                MiniCharacter(character: character.character)
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(character.character) \(character.pinyin)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(InkTheme.ink)
                    Text("\(store.localizedName(for: character)) · \(record.count)x")
                        .font(.system(size: 13))
                        .foregroundStyle(InkTheme.ink3)
                }
                Spacer()
                if store.hasPracticedToday(character.id) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(InkTheme.teal)
                }
            }
        }
    }
}

struct CharacterListRow: View {
    @EnvironmentObject private var store: AppStore
    let character: HanziCharacter

    var body: some View {
        PaperCard(padding: 12) {
            HStack(spacing: 12) {
                MiniCharacter(character: character.character)
                VStack(alignment: .leading, spacing: 5) {
                    Text("\(character.character) \(character.pinyin)")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(InkTheme.ink)
                    Text("\(store.localizedName(for: character)) · \(L10n.themeName(character.theme, store.language))")
                        .font(.system(size: 13))
                        .foregroundStyle(InkTheme.ink3)
                        .lineLimit(2)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 6) {
                    if store.isFavorite(character.id) {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(InkTheme.red)
                    }
                    if store.practiceRecords[character.id] != nil {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(InkTheme.teal)
                    }
                }
            }
        }
    }
}

struct CharacterGridCard: View {
    @EnvironmentObject private var store: AppStore
    let character: HanziCharacter

    var body: some View {
        PaperCard(padding: 12) {
            VStack(alignment: .leading, spacing: 7) {
                HStack(alignment: .top) {
                    Text(character.character)
                        .font(.system(size: 46, weight: .heavy, design: .serif))
                        .foregroundStyle(InkTheme.ink)
                    Spacer()
                    if store.isFavorite(character.id) {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(InkTheme.red)
                    }
                }

                Text(character.pinyin)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(InkTheme.teal)

                Text(store.localizedName(for: character))
                    .font(.system(size: 13))
                    .foregroundStyle(InkTheme.ink3)
                    .lineLimit(2)

                HStack {
                    Text(character.free ? store.text("common.free") : store.text("common.pro"))
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(character.free ? InkTheme.teal : InkTheme.redDeep)
                    Spacer()
                    if store.practiceRecords[character.id] != nil {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(InkTheme.teal)
                    }
                }
            }
            .frame(maxWidth: .infinity, minHeight: 118, alignment: .topLeading)
        }
    }
}

struct InfoBox: View {
    let label: String
    let value: String

    var body: some View {
        PaperCard(padding: 10) {
            VStack(alignment: .leading, spacing: 5) {
                Text(label)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(InkTheme.ink3)
                Text(value)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(InkTheme.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct StrokeHintCell: View {
    let index: Int
    let hint: String

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 8)
                .fill(InkTheme.paperStrong)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(InkTheme.line, lineWidth: 1))
            Text("\(index)")
                .font(.system(size: 10, weight: .heavy))
                .foregroundStyle(InkTheme.redDeep)
                .padding(7)
            Text(hint)
                .font(.system(size: 26, weight: .heavy, design: .serif))
                .foregroundStyle(InkTheme.ink)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(height: 58)
    }
}

struct MiniCharacter: View {
    let character: String

    var body: some View {
        Text(character)
            .font(.system(size: 30, weight: .heavy, design: .serif))
            .foregroundStyle(InkTheme.ink)
            .frame(width: 52, height: 52)
            .background(InkTheme.paperStrong)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(InkTheme.line, lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct IconButtonStyle: ButtonStyle {
    var active: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(active ? InkTheme.red : InkTheme.ink)
            .frame(width: 48, height: 48)
            .background(InkTheme.paperStrong)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(InkTheme.line, lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .opacity(configuration.isPressed ? 0.78 : 1)
    }
}

struct ToolButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Image(systemName: systemImage)
                Text(title)
                    .font(.system(size: 11, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
            .foregroundStyle(InkTheme.ink)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(InkTheme.paperStrong)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(InkTheme.line, lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

struct StatusPill: View {
    let text: String
    let systemImage: String

    var body: some View {
        Label(text, systemImage: systemImage)
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(InkTheme.teal)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(InkTheme.tealSoft)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct ArtworkPreview: View {
    @EnvironmentObject private var store: AppStore
    let character: HanziCharacter
    let template: ArtworkTemplate
    let signature: String

    var body: some View {
        PaperCard {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(previewBackground)
                    .frame(height: 300)

                VStack(spacing: 10) {
                    Text(character.character)
                        .font(.system(size: 132, weight: .heavy, design: .serif))
                        .foregroundStyle(previewInk)
                    Text(signature.isEmpty ? "Hanzi Brush" : signature)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(previewInk.opacity(0.72))
                }

                Text("印")
                    .font(.system(size: 17, weight: .heavy, design: .serif))
                    .foregroundStyle(InkTheme.red)
                    .frame(width: 40, height: 40)
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(InkTheme.red, lineWidth: 2))
                    .offset(x: 88, y: 90)
            }
        }
    }

    private var previewBackground: Color {
        switch template {
        case .ricePaper:
            return InkTheme.paperStrong
        case .cinnabar:
            return Color(hex: 0xF3D7CC)
        case .jade:
            return Color(hex: 0xD9EBE6)
        case .festival:
            return Color(hex: 0xF6E2B9)
        }
    }

    private var previewInk: Color {
        switch template {
        case .cinnabar:
            return InkTheme.redDeep
        case .jade:
            return InkTheme.teal
        default:
            return InkTheme.ink
        }
    }
}

struct TemplateCell: View {
    @EnvironmentObject private var store: AppStore
    let template: ArtworkTemplate
    let selected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 6)
                .fill(color)
                .frame(height: 44)
            Text(L10n.templateName(template, store.language))
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(selected ? InkTheme.redDeep : InkTheme.ink)
        }
        .padding(10)
        .background(selected ? Color(hex: 0xF7E6D6) : InkTheme.paperStrong)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(selected ? InkTheme.red : InkTheme.line, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var color: Color {
        switch template {
        case .ricePaper:
            return InkTheme.paper
        case .cinnabar:
            return Color(hex: 0xF3D7CC)
        case .jade:
            return InkTheme.tealSoft
        case .festival:
            return Color(hex: 0xF6E2B9)
        }
    }
}

struct ArtworkRow: View {
    @EnvironmentObject private var store: AppStore
    let artwork: Artwork
    let onShare: () -> Void

    var body: some View {
        let character = store.character(for: artwork.characterID)
        PaperCard(padding: 12) {
            HStack(spacing: 12) {
                MiniCharacter(character: character.character)
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(character.character) \(store.localizedName(for: character))")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(InkTheme.ink)
                    Text(L10n.templateName(artwork.template, store.language))
                        .font(.system(size: 13))
                        .foregroundStyle(InkTheme.ink3)
                }
                Spacer()
                Button(action: onShare) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundStyle(InkTheme.teal)
                }
                Button(role: .destructive) {
                    store.deleteArtwork(artwork)
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(InkTheme.red)
                }
            }
        }
    }
}

struct FilterChip: View {
    let title: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(selected ? InkTheme.paperStrong : InkTheme.ink2)
                .padding(.horizontal, 13)
                .frame(height: 34)
                .background(selected ? InkTheme.teal : InkTheme.paperStrong)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(selected ? InkTheme.teal : InkTheme.line, lineWidth: 1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

struct SettingsLinkRow: View {
    let systemImage: String
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            PaperCard(padding: 12) {
                HStack(spacing: 12) {
                    Image(systemName: systemImage)
                        .foregroundStyle(InkTheme.teal)
                        .frame(width: 38, height: 38)
                        .background(InkTheme.tealSoft)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(InkTheme.ink)
                        Text(subtitle)
                            .font(.system(size: 12))
                            .foregroundStyle(InkTheme.ink3)
                            .lineLimit(2)
                    }
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .foregroundStyle(InkTheme.redDeep)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

struct ToastView: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.system(size: 14, weight: .bold))
            .foregroundStyle(InkTheme.paperStrong)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(InkTheme.ink)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .shadow(color: InkTheme.ink.opacity(0.22), radius: 10, x: 0, y: 6)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
