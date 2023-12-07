//
//  MenuView.swift
//  ClassicUI
//
//  Created by Austin Bennett on 11/24/23.
//

import SwiftUI

struct MenuView: View {
    @Binding var menus:[Menu]
    @Binding var menuIndex:Int?
    
    var body: some View {
        ScrollViewReader { value in
            ScrollView {
                ForEach(self.menus) { menu in
                    HStack() {
                        Text(menu.name)
                            .font(.system(size: 25))
                        Spacer()
                        if(menu.next) {
                            Image(systemName: "chevron.right")
                        }
                    }
                    .padding(.horizontal, 5)
                    .foregroundColor(menu.id == self.menuIndex! ? .white : .black)
                    .background(menu.id == self.menuIndex! ? Color.blue : Color.white)
                }
            }
            .scrollPosition(id: $menuIndex)
        }
    }
}

struct MenuView_Preview: PreviewProvider {
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
    
    static var previews: some View {
        GeometryReader { geometry in
            HStack {
                VStack {
                    Text("iPod")
                        .font(.system(size: 25))
                        .frame(width: geometry.size.width * 0.95, height: 30.0)
                        .background(Color.gray)
                    MenuView(menus: $menus, menuIndex: $menuIndex)
                }
                .frame(width: geometry.size.width * 0.95, height: 300)
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .overlay(RoundedRectangle(cornerRadius: 5).stroke(lineWidth: 2).foregroundColor(.gray))
            }
            .offset(x: 10)
        }
    }
}
