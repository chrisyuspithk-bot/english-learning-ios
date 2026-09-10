import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    welcomeHeader

                    if store.isLoadingContent {
                        HStack {
                            Spacer()
                            ActivityIndicator()
                            Spacer()
                        }
                        .padding(.top, 40)
                    } else {
                        if let latest = store.homework.first {
                            homeworkCard(latest)
                        }
                        if let announcement = store.announcements.first {
                            announcementCard(announcement)
                        }
                        chaptersSection
                    }
                }
                .padding(.vertical)
            }
            .background(Theme.background)
            .navigationBarTitle("Home", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: { store.logout() }) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
            })
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    // MARK: - Welcome

    private var welcomeHeader: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(hex: store.user?.avatarColorHex ?? "4F8EF7"))
                    .frame(width: 56, height: 56)
                Text(initials)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("Hello, \(store.user?.englishName ?? "Student") 👋")
                    .font(.headline)
                    .fontWeight(.bold)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal)
    }

    private var initials: String {
        let name = store.user?.englishName ?? "S"
        return String(name.prefix(1))
    }

    private var subtitle: String {
        let grade = store.user?.grade ?? ""
        let school = store.user?.school ?? ""
        return school.isEmpty ? grade : "\(grade) · \(school)"
    }

    // MARK: - Homework

    private func homeworkCard(_ homework: HomeworkSession) -> some View {
        Card(accent: Theme.primary) {
            HStack {
                Text("📚 Latest Homework")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                Spacer()
                if let score = homework.score {
                    Text("\(score)/100")
                        .font(.footnote)
                        .fontWeight(.bold)
                        .foregroundColor(score >= 60 ? Theme.success : Theme.danger)
                }
            }
            Text(homework.title)
                .font(.headline)
            HStack {
                Text(homework.type)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Theme.primary.opacity(0.15))
                    .foregroundColor(Theme.primary)
                    .cornerRadius(6)
                Text("Due \(homework.dueDate)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            ProgressBar(value: homework.progress)
            Text("\(Int(homework.progress * 100))% completed")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
    }

    // MARK: - Announcement

    private func announcementCard(_ announcement: Announcement) -> some View {
        Card(accent: Theme.accent) {
            HStack {
                Text("📢 Teacher Announcement")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                Spacer()
                Text(announcement.date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Text(announcement.title)
                .font(.headline)
            Text(announcement.body)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            Text("— \(announcement.author)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
    }

    // MARK: - Chapters

    private var chaptersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Chapters", icon: "books.vertical.fill")

            ForEach(store.chapters) { chapter in
                NavigationLink(destination: ChapterDetailView(summary: chapter)) {
                    chapterRow(chapter)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }

    private func chapterRow(_ chapter: ChapterSummary) -> some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: chapter.colorHex))
                    .frame(width: 52, height: 52)
                Image(systemName: chapter.icon)
                    .foregroundColor(.white)
                    .font(.system(size: 22))
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("Chapter \(chapter.number)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(chapter.title)
                    .font(.headline)
                Text(chapter.subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Theme.cardBackground)
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

// MARK: - Progress bar (iOS 13 friendly)

struct ProgressBar: View {
    let value: Double

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                RoundedRectangle(cornerRadius: 4)
                    .fill(Theme.primary)
                    .frame(width: geo.size.width * CGFloat(max(0, min(1, value))))
            }
        }
        .frame(height: 8)
    }
}
