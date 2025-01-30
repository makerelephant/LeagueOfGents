//
//  LeagueOfGentsApp.swift
//  LeagueOfGents
//
//  Created by mark Slater on 1/30/25.
//

import SwiftUI

@main
struct LeagueOfGentsApp: App {
    @State private var isActive = false
    private let imageArray = ["image1", "image2", "image3", "image4", "image5"]
    private let selectedImage: String

    init() {
        selectedImage = imageArray.randomElement() ?? "defaultImage"
    }

    var body: some Scene {
        WindowGroup {
            if isActive {
                ContentView()
            } else {
                LaunchScreenView(imageName: selectedImage)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            isActive = true
                        }
                    }
            }
        }
    }
}
