//
//  DisplayView.swift
//  ClassicUI
//
//  Created by Austin Bennett on 11/23/23.
//

import SwiftUI

struct DisplayView: View {
    @Binding var menus:[Menu]
    @Binding var menuIndex:Int?
    @Binding var currentView:AnyView
    @Binding var previousView:AnyView
    var title:String
    
    //TODO: See if we can't flip the ForEach menu loop to being a separate view entirely that we can update with custom views (We may need to build a view controller in order to do the slide animation
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .font(.system(size: 25))
                    .frame(width: geometry.size.width * 0.95, height: 30.0)
                    .background(Color.gray)
//                MenuView(menus: $menus, menuIndex: $menuIndex)
//                    .background(Color.white)
                currentView
                    .background(Color.white)
            }
            .frame(width: geometry.size.width * 0.95, height: 300)
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .overlay(RoundedRectangle(cornerRadius: 5).stroke(lineWidth: 2).foregroundColor(.gray))
        }
        .task {
            currentView = AnyView(MenuView(menus: $menus, menuIndex: $menuIndex))
        }
    }
}

struct DisplayManager {
    var current:MenuOrNowPlaying
    var previous:MenuOrNowPlaying
}

enum MenuOrNowPlaying:Equatable {
    static func == (lhs: MenuOrNowPlaying, rhs: MenuOrNowPlaying) -> Bool {
        return false
    }
    
    case NowPlaying(NowPlayingView)
    case Menu(MenuView)
}

struct DisplayView_Preview: PreviewProvider {
    @State static var menus:[Menu] = [
        Menu(id: 0, name: "Music", next: true),
        Menu(id: 1, name: "Videos", next: true),
        Menu(id: 2, name: "Photos", next: true),
        Menu(id: 3, name: "Podcasts", next: true),
        Menu(id: 4, name: "Extras", next: true),
        Menu(id: 5, name: "Settings", next: true),
        Menu(id: 6, name: "Shuffle Songs", next: false)
    ]
    @State static var menuIndex:Int? = 0
    @State static var current:AnyView = AnyView(Text(""))
    @State static var previousView:AnyView = AnyView(Text(""))
    
    static var previews: some View {
        HStack {
            Spacer()
//            DisplayView(menus: $menus, menuIndex: $menuIndex, title: "iPod")
            DisplayView(menus: $menus, menuIndex: $menuIndex, currentView: $current, previousView: $previousView, title: "iPod")
                .onAppear {
                    current = AnyView(MenuView(menus: $menus, menuIndex: $menuIndex))
                }
            Spacer()
        }
        .frame(width: 400)
        .offset(x: 10)
    }
}
