import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: BatchTanStore
    @EnvironmentObject private var purchases: PurchaseManager
    @AppStorage("batchtan_haptics_enabled") private var hapticsEnabled: Bool = true
    @AppStorage("batchtan_show_notes") private var showNotes: Bool = true

    @State private var showingDeleteConfirm = false
    @State private var showingPaywall = false
    @State private var showingAdd = false

    var body: some View {
        NavigationStack {
            ZStack {
                BTTheme.backdrop.ignoresSafeArea()

                Form {
                    Section {
                        if purchases.isPro {
                            HStack {
                                Image(systemName: "checkmark.seal.fill").foregroundStyle(BTTheme.accent)
                                Text("Batch Tan Pro active")
                                    .foregroundStyle(BTTheme.ink)
                            }
                        } else {
                            Button {
                                showingPaywall = true
                            } label: {
                                HStack {
                                    Image(systemName: "star.fill").foregroundStyle(BTTheme.accent2)
                                    Text("Unlock Pro")
                                        .foregroundStyle(BTTheme.ink)
                                    Spacer()
                                    Image(systemName: "chevron.right").foregroundStyle(BTTheme.inkFaded)
                                }
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("settingsUnlockProButton")
                        }
                    }
                    .listRowBackground(BTTheme.card)

                    if purchases.isPro {
                        Section("Stage Countdown Timers") {
                            Text("Countdown timers per stage with chemical ratio reference.")
                                .font(.caption)
                                .foregroundStyle(BTTheme.inkFaded)
                            ForEach(store.proEntries) { p in
                                HStack {
                                    Text(p.chemical)
                                        .foregroundStyle(BTTheme.ink)
                                    Spacer()
                                    Text(p.ratio)
                                        .font(.caption)
                                        .foregroundStyle(BTTheme.accent)
                                }
                            }
                            .onDelete { offsets in
                                for idx in offsets { store.deleteProEntry(store.proEntries[idx].id) }
                            }
                        }
                        .listRowBackground(BTTheme.card)
                    }

                    Section("Preferences") {
                        Toggle("Haptic Feedback", isOn: $hapticsEnabled)
                            .onChange(of: hapticsEnabled) { _, newValue in
                                BTHaptics.enabled = newValue
                            }
                        Toggle("Show Notes", isOn: $showNotes)
                    }
                    .listRowBackground(BTTheme.card)

                    Section {
                        Button {
                            if store.canAdd(isPro: purchases.isPro) {
                                showingAdd = true
                            } else {
                                showingPaywall = true
                            }
                        } label: {
                            Label("Add Entry", systemImage: "plus")
                        }
                        .accessibilityIdentifier("settingsAddHideButton")
                    }
                    .listRowBackground(BTTheme.card)

                    Section {
                        Link("Privacy Policy", destination: URL(string: "https://shimondeitel.github.io/batchtan-app/privacy.html")!)
                        Link("Terms of Use", destination: URL(string: "https://shimondeitel.github.io/batchtan-app/terms.html")!)
                        Button("Restore Purchases") {
                            Task { await purchases.restore() }
                        }
                    }
                    .listRowBackground(BTTheme.card)

                    Section {
                        Button("Delete All Data", role: .destructive) {
                            showingDeleteConfirm = true
                        }
                    }
                    .listRowBackground(BTTheme.card)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .confirmationDialog("Delete all data? This cannot be undone.", isPresented: $showingDeleteConfirm, titleVisibility: .visible) {
                Button("Delete Everything", role: .destructive) {
                    store.deleteAllData()
                }
                Button("Cancel", role: .cancel) {}
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showingAdd) {
                HideFormView(mode: .add)
            }
        }
    }
}
