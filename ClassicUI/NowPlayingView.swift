//
//  NowPlayingView.swift
//  ClassicUI
//
//  Created by Austin Bennett on 11/24/23.
//

import SwiftUI
import MusicKit

struct NowPlayingView: View {
    var song:Song //TODO: Fetch Now Playing Song
    var previousMenu:[Menu]
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                HStack {
                    ZStack {
                        Rectangle()
                            .frame(width: 100, height: 100)
                            .background(Color(red: (110.0/255.0), green: (110.0/255.0), blue: (110.0/255.0)))
                        AsyncImage(url: song.artwork?.url(width: 100, height: 100))
                            .frame(width: 100, height: 100)
                    }
                    VStack(alignment: .leading) {
                        Text("\(song.title)")
                            .frame(width: 240, alignment: .leading)
                            .fixedSize()
                        Text("\(song.artistName)")
                            .frame(width: 240, alignment: .leading)
                            .fixedSize()
                        Text("\(song.albumTitle ?? "")")
                            .frame(width: 360 - 100 - 20, alignment: .leading)
                            .fixedSize()
//                            .frame(width: 360 - 100 - 20, alignment: .trailing)
                    }
                    .foregroundStyle(Color.black)
                    .font(.system(size: 25))
                    .offset(x: 20)
                    Spacer()
                }
                .offset(x: 30)
                Spacer()
                Spacer()
                ProgressView(timerInterval: Date()...Date().addingTimeInterval(song.duration ?? 180), countsDown: false)
                    .frame(width: 320)
                    .foregroundStyle(Color.black)
                    .task {
                        print("Duration: \(song.duration ?? 180)")
                    }
                Spacer()
            }
            .task {
                do {
                    let mp = SystemMusicPlayer.shared
                    mp.stop()
                    try await mp.prepareToPlay()
                    try await mp.queue.insert(song, position: MusicPlayer.Queue.EntryInsertionPosition.afterCurrentEntry)
                    try await mp.play()
                } catch {
                    print("Error starting song...")
                }
            }
        }
    }
}

struct NowPlayingView_Preview: PreviewProvider {
    @State static var song:Song?
    
    static var previews: some View {
        GeometryReader { geometry in
            HStack {
                VStack {
                    Text("iPod")
                        .font(.system(size: 25))
                        .frame(width: geometry.size.width * 0.95, height: 30.0)
                        .background(Color.gray)
                    NowPlayingView(song: song!, previousMenu: [])
                }
                .frame(width: geometry.size.width * 0.95, height: 300)
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .overlay(RoundedRectangle(cornerRadius: 5).stroke(lineWidth: 2).foregroundColor(.gray))
            }
            .offset(x: 10)
        }
        .task {
            song = await loadLibrarySongs()!.items[0]
        }
    }
    
    private static func loadLibrarySongs() async -> MusicLibraryResponse<Song>? {
        do {
            let request = MusicLibraryRequest<Song>()
            let response = try await request.response()
            return response
        } catch {
        }
        return nil
    }
}
