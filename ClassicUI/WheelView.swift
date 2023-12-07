//
//  WheelView.swift
//  ClassicUI
//
//  Created by Austin Bennett on 11/23/23.
//

import SwiftUI
import AVFoundation
import MusicKit

struct WheelView: View {
    @Binding var menus: [Menu]
    @Binding var menuIndex: Int?
    @Binding var displayTitle: String
    @Binding var currentView:AnyView
    @Binding var previousView:AnyView
    
    var mainMenu: [Menu] = [
        Menu(id: 0, name: "Music", next: true),
        Menu(id: 1, name: "Photos", next: true),
        Menu(id: 2, name: "Videos", next: true),
        Menu(id: 3, name: "Extras", next: true),
        Menu(id: 4, name: "Settings", next: true),
        Menu(id: 5, name: "Shuffle Songs", next: false)
    ]
    
    var musicMenu: [Menu] = [
        Menu(id: 0, name: "Playlists", next: true),
        Menu(id: 1, name: "Artists", next: true),
        Menu(id: 2, name: "Albums", next: true),
        Menu(id: 3, name: "Songs", next: true),
        Menu(id: 4, name: "Podcasts", next: true),
        Menu(id: 5, name: "Genres", next: true),
        Menu(id: 6, name: "Composers", next: true),
        Menu(id: 7, name: "Audiobooks", next: true)
    ]
    
    var extrasMenu: [Menu] = []
    var settingsMenu: [Menu] = []
    
    private let player = ApplicationMusicPlayer.shared
    
    @State private var playlists:MusicLibraryResponse<Playlist>? = nil
    @State private var songs:MusicLibraryResponse<Song>? = nil
    @State var selectedSection:SongFilter = .started
    @State var previousTitles: [String] = []
    @State private var lastAngle: CGFloat = 0
    @State private var counter: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Circle()
                    .frame(width: 1, height: 1)
                    .background(Color.red)
                    .task {
                        playlists = await loadLibraryPlaylists()
                        songs = await loadLibrarySongs()
                    }
                Circle()
                    .frame(width: geometry.size.width, height: geometry.size.width)
                    .foregroundColor(Color("Wheel"))
                    .gesture(
                        DragGesture()
                            .onChanged{ v in
                                var angle = atan2(v.location.x - geometry.size.width / 2, geometry.size.width / 2 - v.location.y) * 180 / .pi
                                if angle < 0 { angle += 360 }
                                let theta = self.lastAngle - angle
                                self.lastAngle = angle
                                if abs(theta) < 20 {
                                    self.counter += theta
                                }
                                if(self.counter > 20 && self.menuIndex! > 0) {
                                    self.menuIndex! -= 1
                                    AudioServicesPlaySystemSound(1104)
                                } else if (self.counter < -20 && self.menuIndex! < self.menus.count - 1) {
                                    self.menuIndex! += 1
                                    AudioServicesPlaySystemSound(1104)
                                }
                                if(abs(self.counter) > 20) { self.counter = 0}
                            }
                            .onEnded { v in
                                self.counter = 0
                            }
                    )
                    .overlay(
                        Circle()
                            .frame(width:geometry.size.width * 0.35, height: geometry.size.width * 0.35)
                            .foregroundColor(Color("Shell"))
                            .gesture(
                                TapGesture(count: 1)
                                    .onEnded {
                                        AudioServicesPlaySystemSound(1104)
                                        print("Tapped \(menus[menuIndex!].name)")
                                        previousView = currentView
                                        //TODO: Send Menu Select Event to DisplayView
                                        if !menus[menuIndex!].name.contains("Shuffle Songs") {
                                            self.previousTitles.append(contentsOf: ["\(displayTitle)"])
                                            displayTitle = "\(menus[menuIndex!].name)"
                                        }
                                        if menus[menuIndex!].name.contains("Music") {
                                            menus = musicMenu
                                            menuIndex = 0
                                        } else if menus[menuIndex!].name.contains("Playlists") {
//                                            print("Playlist:", playlists)
                                            var musicPlaylists:[String] = []
                                            if let plist = playlists {
                                                for list in plist.items {
                                                    musicPlaylists.append(list.name)
                                                }
                                            }
                                            selectedSection = .playlist
                                            setMenuView(items: musicPlaylists, next: true)
                                        } else if menus[menuIndex!].name.contains("Songs") {
                                            let songsList:[String] = getSection(filter: .none)
                                            setMenuView(items: songsList, next: false)
                                        } else if menus[menuIndex!].name.contains("Artists") {
                                            let artistsList:[String] = getSection(filter: .artist)
                                            setMenuView(items: artistsList, next: true)
                                        } else if menus[menuIndex!].name.contains("Albums") {
                                            let albumsList:[String] = getSection(filter: .album)
                                            setMenuView(items: albumsList, next: true)
                                        } else if menus[menuIndex!].name.contains("Genres") {
                                            let genresList:[String] = getSection(filter: .genre)
                                            setMenuView(items: genresList, next: true)
                                        } else if selectedSection != .started {
                                            if let music = songs {
                                                var song:Song?
                                                for item in music.items {
                                                    if item.title.contains(menus[menuIndex!].name) {
                                                        song = item
                                                        break
                                                    }
                                                }
                                                if let s = song {
//                                                    menus = [Menu(id: 0, name: "\(s.title) by \(s.artistName)", next: false)]
                                                    currentView = AnyView(NowPlayingView(song: s, previousMenu: menus))
                                                    displayTitle = "Now Playing"
                                                }
                                            }
                                        }
//                                        } else if selectedSection == .playlist {
//                                            var mPlaylists: [String] = []
//                                            if let plist = playlists {
//                                                for list in plist.items {
//                                                    mPlaylists.append(list.name)
//                                                }
//                                            }
//                                            if !mPlaylists.contains(menus[menuIndex!].name) {
//                                                displayTitle = "Now Playing"
//                                                
//                                            }
//                                        }
                                    })
                    )
                Text("MENU")
                    .font(.title)
                    .foregroundColor(.white)
                    .offset(y: -140)
                    .gesture( TapGesture(count: 1)
                        .onEnded {
                            if previousTitles.count > 0 {
                                displayTitle = "\(previousTitles.removeLast())"
                                switch displayTitle {
                                case "Music":
                                    menus = musicMenu
                                    menuIndex = 0
                                    selectedSection = .none
                                    break
                                case "iPod":
                                    menus = mainMenu
                                    menuIndex = 0
                                    break
                                case "Videos":
                                    menus = mainMenu
                                    menuIndex = 0
                                    break
                                case "Photos":
                                    menus = mainMenu
                                    menuIndex = 0
                                    break
                                case "Extras":
                                    menus = mainMenu
                                    menuIndex = 0
                                    break
                                case "Settings":
                                    menus = mainMenu
                                    menuIndex = 0
                                    break
                                default:
                                    currentView = previousView
                                    break
                                }
                            }
                        })
                Image(systemName: "playpause.fill")
                    .font(.title)
                    .foregroundColor(.white)
                    .offset(y: 140)
                    .gesture(TapGesture(count: 1)
                        .onEnded {
                            Task {
                                let mp = SystemMusicPlayer.shared
                                do {
                                    if mp.state.playbackStatus == .playing {
                                        mp.pause()
                                    } else {
                                        try await mp.play()
                                    }
                                } catch {
                                }
                            }
                        })
                Image(systemName: "forward.end.alt.fill")
                    .font(.title)
                    .foregroundColor(.white)
                    .offset(x: 140)
                    .gesture(TapGesture(count:1)
                        .onEnded {
                            Task {
                                let mp = SystemMusicPlayer.shared
                                do {
                                    try await mp.skipToNextEntry()
                                } catch {
                                }
                            }
                        })
                Image(systemName: "backward.end.alt.fill")
                    .font(.title)
                    .foregroundColor(.white)
                    .offset(x: -140)
                    .gesture(TapGesture(count:1)
                        .onEnded {
                            Task {
                                let mp = SystemMusicPlayer.shared
                                do {
                                    try await mp.skipToPreviousEntry()
                                } catch {
                                }
                            }
                        })
            }
        }
    }
    
    private func loadLibraryPlaylists() async -> MusicLibraryResponse<Playlist>? {
        do {
            let request = MusicLibraryRequest<Playlist>()
            let response = try await request.response()
            return response
        } catch {
        }
        return nil
    }
    
    private func loadSongsFromPlaylist(playlistName:String) async -> MusicItemCollection<Song>? {
        do {
            let request = MusicLibrarySearchRequest(term: "\(playlistName)", types: [Song.self, Playlist.self])
            let response = try await request.response()
            return response.songs
        } catch {
        }
        return nil
    }
    
    private func loadLibrarySongs() async -> MusicLibraryResponse<Song>? {
        do {
            let request = MusicLibraryRequest<Song>()
            let response = try await request.response()
            return response
        } catch {
        }
        return nil
    }
    
    private func setMenuView(items:[String], next:Bool) {
        menus = []
        for i in 0..<items.count {
            menus.append(Menu(id: i, name: items[i], next: next))
        }
    }
    
    private func getSection(filter: SongFilter) -> [String] {
        selectedSection = filter
        var toReturn:[String] = []
        if let slist = songs {
            for song in slist.items {
                if filter == .none {
                    toReturn.append(song.title)
                } else if filter == .album {
                    if let albTitle = song.albumTitle {
                        if !toReturn.contains(albTitle) {
                            toReturn.append(albTitle)
                        }
                    }
                } else if filter == .artist {
                    if !toReturn.contains(song.artistName) {
                        toReturn.append(song.artistName)
                    }
                } else if filter == .genre {
                    for genre in song.genreNames {
                        if !toReturn.contains(genre) {
                            toReturn.append(genre)
                        }
                    }
                }
            }
        }
        toReturn.sort()
        return toReturn
    }
}

enum SongFilter {
    case none
    case album
    case artist
    case genre
    case playlist
    case started
}

struct WheelView_Preview: PreviewProvider {
    @State static var menus = [
        Menu(id: 0, name: "Music", next: true),
        Menu(id: 1, name: "Photos", next: true),
        Menu(id: 2, name: "Videos", next: true),
        Menu(id: 3, name: "Shuffle Songs", next: false)
    ]
    @State static var menuIndex:Int? = 0
    @State static var displayTitle: String = "iPod"
    @State static var currentView:AnyView = AnyView(Text(""))
    @State static var previousView:AnyView = AnyView(Text(""))
    
    static var previews: some View {
        WheelView(menus: $menus, menuIndex: $menuIndex, displayTitle: $displayTitle, currentView: $currentView, previousView: $previousView)
    }
}
