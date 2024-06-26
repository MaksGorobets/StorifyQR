//
//  StorifyQRApp.swift
//  StorifyQR
//
//  Created by Maks Winters on 01.01.2024.
//
// https://www.youtube.com/watch?v=2D05dGo3jB4
//
// https://www.youtube.com/watch?v=kbgNL7VrQPo
//
// https://stackoverflow.com/questions/24591167/how-to-get-current-language-code-with-swift
//

import SwiftUI
import TipKit

@main
struct StorifyQRApp: App {
    
    @State private var mapViewModel = MapViewModel(editingLocation: nil)
    @AppStorage("ONBOARDING") var showOnboarding = true
    @AppStorage("LANGUAGE") var savedLanguage = ""
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    checkForLangChange()
                }
                .task {
                    configureTips()
                }
                .sheet(isPresented: $showOnboarding) {
                    OnboardingView()
                }
        }
        .environment(mapViewModel)
//        .modelContainer(for: StoredItem.self) this is the cause of Sheet closing automatically when using MVVM SwiftData implementation.
    }
    
    func configureTips() {
        try? Tips.configure([
            .datastoreLocation(.applicationDefault)
        ])
    }
    
    func checkForLangChange() {
        let languageCode = Locale.current.language.languageCode?.identifier
        if savedLanguage != languageCode {
            guard let sl = languageCode else { return }
            savedLanguage = sl
            showOnboarding = true
        }
    }
    
}
