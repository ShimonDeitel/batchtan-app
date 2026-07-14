import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            HideListView()
                .tabItem { Label("Home", systemImage: "list.bullet.clipboard") }
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
        .tint(BTTheme.accent)
    }
}

struct HideListView: View {
    @EnvironmentObject private var store: BatchTanStore
    @EnvironmentObject private var purchases: PurchaseManager
    @State private var showingAdd = false
    @State private var showingPaywall = false
    @State private var editingItem: Hide?

    var body: some View {
        NavigationStack {
            ZStack {
                BTTheme.backdrop.ignoresSafeArea()
                if store.hides.isEmpty {
                    ContentUnavailableView("No Hides Yet", systemImage: "square.stack.3d.up", description: Text("Tap + to log your first entry."))
                } else {
                    List {
                        ForEach(store.hides) { item in
                            HideRow(item: item)
                                .listRowBackground(BTTheme.card)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    editingItem = item
                                }
                                .swipeActions {
                                    Button(role: .destructive) {
                                        store.deleteHide(item.id)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Batch Tan")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAdd(isPro: purchases.isPro) {
                            showingAdd = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addHideButton")
                }
            }
            .sheet(isPresented: $showingAdd) {
                HideFormView(mode: .add)
            }
            .sheet(item: $editingItem) { item in
                HideFormView(mode: .edit(item))
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
    }
}

struct HideRow: View {
    let item: Hide

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.species)
                .font(BTTheme.headlineFont)
                .foregroundStyle(BTTheme.ink)
            Text(String(describing: item.stage))
                .font(.caption)
                .foregroundStyle(BTTheme.inkFaded)
        }
        .padding(.vertical, 4)
    }
}

enum HideFormMode: Identifiable {
    case add
    case edit(Hide)

    var id: String {
        switch self {
        case .add: return "add"
        case .edit(let item): return item.id.uuidString
        }
    }
}

struct HideFormView: View {
    @EnvironmentObject private var store: BatchTanStore
    @EnvironmentObject private var purchases: PurchaseManager
    @Environment(\.dismiss) private var dismiss

    let mode: HideFormMode

    @State private var draftSpecies: String = ""
    @State private var draftStage: String = ""
    @State private var draftSoakStart: Date = Date()
    @State private var draftNotes: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                BTTheme.backdrop.ignoresSafeArea()
                Form {
                    Section {
                TextField("Species", text: $draftSpecies)
                    .accessibilityIdentifier("speciesField")
                Picker("Stage", selection: $draftStage) {
                    ForEach(BTStageOption.all, id: \.self) { Text($0) }
                }
                DatePicker("Soak Start", selection: $draftSoakStart, displayedComponents: .date)
                TextField("Notes", text: $draftNotes)
                    .accessibilityIdentifier("notesField")
                    }
                    .listRowBackground(BTTheme.card)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(isEditing ? "Edit Entry" : "New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .accessibilityIdentifier("hideSaveButton")
                }
            }
            .onAppear { loadIfEditing() }
            .dismissKeyboardOnTap()
        }
    }

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    private func loadIfEditing() {
        if case .edit(let item) = mode {
        draftSpecies = item.species
        draftStage = item.stage
        draftSoakStart = item.soakStart
        draftNotes = item.notes
        } else {
        draftSpecies = ""
        draftStage = ""
        draftSoakStart = Date()
        draftNotes = ""
        }
    }

    private func save() {
        switch mode {
        case .add:
            store.addHide(species: draftSpecies, stage: draftStage, soakStart: draftSoakStart, notes: draftNotes, isPro: purchases.isPro)
        case .edit(let item):
            store.updateHide(item.id, species: draftSpecies, stage: draftStage, soakStart: draftSoakStart, notes: draftNotes)
        }
        BTHaptics.success()
        dismiss()
    }
}
