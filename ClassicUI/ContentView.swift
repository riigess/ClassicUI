//
//  ContentView.swift
//  ClassicUI
//
//  Created by Austin Bennett on 11/23/23.
//

import SwiftUI
import StoreKit

struct Menu: Identifiable {
    let id: Int
    let name: String
    let next: Bool
}

struct ContentView: View {
    @State private var menus: [Menu] = [
        Menu(id: 0, name: "Music", next: true),
        Menu(id: 1, name: "Videos", next: true),
        Menu(id: 2, name: "Photos", next: true),
        Menu(id: 3, name: "Podcasts", next: true),
        Menu(id: 4, name: "Extras", next: true),
        Menu(id: 5, name: "Settings", next: true),
        Menu(id: 6, name: "Shuffle Songs", next: true),
        Menu(id: 7, name: "Now Playing", next: false)
    ]
    @State private var musicMenu: [Menu] = [
        Menu(id: 0, name: "Playlists", next: true),
        Menu(id: 1, name: "Artists", next: true),
        Menu(id: 2, name: "Albums", next: true),
        Menu(id: 3, name: "Songs", next: true),
        Menu(id: 4, name: "Podcasts", next: true),
        Menu(id: 5, name: "Genres", next: true),
        Menu(id: 6, name: "Composers", next: true),
        Menu(id: 7, name: "Audiobooks", next: false)
    ]
    @State private var menuIndex: Int? = 0
    @State private var displayTitle: String = "iPod"
    @State private var currentView:AnyView = AnyView(Text(""))
    @State private var previousView:AnyView = AnyView(Text(""))
    
    var body: some View {
        VStack {
            VStack {
                Spacer()
                DisplayView(menus: $menus, menuIndex: $menuIndex, currentView: $currentView, previousView: $previousView, title: displayTitle)
                    .offset(x: 10)
                    .onAppear {
                        currentView = AnyView(MenuView(menus: $menus, menuIndex: $menuIndex))
                    }
                Spacer()
                WheelView(menus: $menus, menuIndex: $menuIndex, displayTitle: $displayTitle, currentView: $currentView, previousView: $previousView)
                    .frame(width: 360)
                Spacer()
            }
        }
        .background(Color("Shell"))
        .onAppear {
            if SKCloudServiceController.authorizationStatus() == .notDetermined {
                SKCloudServiceController.requestAuthorization {(status: SKCloudServiceAuthorizationStatus) in
                    switch status {
                    case .denied, .restricted:
                        print("Unable to access AM Library")
                        break
                    case .authorized:
                        print("Able to access AM Library :)")
                        break
                    default: break
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
