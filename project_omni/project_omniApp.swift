//
//  project_omniApp.swift
//  project_omni
//
//  Created by swaroop reddy vontela on 12/06/26.
//

import SwiftUI

@main
struct project_omniApp: App {
    @State private var authManager = AuthManager()

    var body: some Scene {
        WindowGroup {
            Group {
                if authManager.session != nil {
                    HomeView()
                } else {
                    LoginView()
                }
            }
            .environment(authManager)
        }
    }
}
