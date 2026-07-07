import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showingAdd = false
    @State private var showingPaywall = false
    @State private var showingSettings = false
    @State private var editingEntry: WhiskeyEntry?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                if store.entries.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(store.entries) { entry in
                            entryRow(entry)
                                .listRowBackground(Theme.background)
                                .contentShape(Rectangle())
                                .onTapGesture { editingEntry = entry }
                        }
                        .onDelete { offsets in store.delete(at: offsets) }
                    }
                    .scrollContentBackground(.hidden)
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Tasting Flight")
            .toolbarBackground(Theme.background, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("settingsButton")
                    .tint(Theme.accent)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAddMore {
                            showingAdd = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addButton")
                    .tint(Theme.accent)
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddEntrySheet(entry: nil)
            }
            .sheet(item: $editingEntry) { entry in
                AddEntrySheet(entry: entry)
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
        .tint(Theme.accent)
        .preferredColorScheme(.dark)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "square.stack.3d.up")
                .font(.system(size: 48))
                .foregroundColor(Theme.accent)
            Text("No entries yet")
                .font(Theme.headingFont)
                .foregroundColor(Theme.textPrimary)
            Text("Tap + to add your first whiskey.")
                .font(Theme.bodyFont)
                .foregroundColor(Theme.textSecondary)
        }
    }

    private func entryRow(_ entry: WhiskeyEntry) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(entry.title)
                .font(Theme.headingFont)
                .foregroundColor(Theme.textPrimary)
            Text(String(describing: entry.distillery))
                .font(Theme.captionFont)
                .foregroundColor(Theme.textSecondary)
            HStack {
                ForEach(0..<5) { i in
                    Image(systemName: i < entry.rating ? "star.fill" : "star")
                        .font(.caption)
                        .foregroundColor(Theme.accent)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct AddEntrySheet: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) var dismiss
    let entry: WhiskeyEntry?

    @State private var title: String = ""
    @State private var rating: Int = 3
    @State private var draftDistillery: String = ""
    @State private var draftAge: Double = 0
    @State private var draftRegion: String = ""
    @State private var draftNotes: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Title", text: $title)
                        .accessibilityIdentifier("field_title")
                    TextField("Distillery", text: $draftDistillery)
                        .accessibilityIdentifier("field_distillery")
                    TextField("Age (years)", value: $draftAge, format: .number)
                        .keyboardType(.decimalPad)
                        .accessibilityIdentifier("field_age")
                    TextField("Region", text: $draftRegion)
                        .accessibilityIdentifier("field_region")
                    TextField("Tasting notes", text: $draftNotes)
                        .accessibilityIdentifier("field_notes")
                    Stepper("Rating: \(rating)", value: $rating, in: 1...5)
                        .accessibilityIdentifier("field_rating")
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .contentShape(Rectangle())
            .onTapGesture {
                hideKeyboard()
            }
            .navigationTitle(entry == nil ? "Add Whiskey" : "Edit Whiskey")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("cancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                        dismiss()
                    }
                    .accessibilityIdentifier("saveButton")
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear { populateIfEditing() }
        }
    }

    private func populateIfEditing() {
        guard let entry else { return }
        title = entry.title
        rating = entry.rating
    }

    private func save() {
        if var existing = entry {
            existing.title = title
            existing.rating = rating
            store.update(existing)
        } else {
            let newEntry = WhiskeyEntry(title: title, rating: rating, distillery: draftDistillery, age: draftAge, region: draftRegion, notes: draftNotes)
            store.add(newEntry)
        }
        draftDistillery = ""
        draftAge = 0
        draftRegion = ""
        draftNotes = ""
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
