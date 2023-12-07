//
//  PhotosView.swift
//  ClassicUI
//
//  Created by Austin Bennett on 11/25/23.
//

import SwiftUI
import Photos

struct PhotosView: View {
    var photos:[[CGImage]]
    var size:CGFloat = 60.0
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                ForEach(photos.indices) { photoRow in
                    HStack {
                        ForEach(photos[photoRow].indices) { photo in
                            ZStack {
                                Rectangle()
                                    .frame(width: size-2, height: size-2)
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(lineWidth: 2).foregroundColor(.gray))
                                Image(photos[photoRow][photo] as! String)
                                    .frame(width: size, height: size)
                            }
                        }
                    }
                }
            }
            .frame(width: geometry.size.width, alignment: .center)
        }
    }
}

struct PhotosView_Previews: PreviewProvider {
    static var photos:[[CGImage]] = [[]]
    
    static var previews: some View {
        GeometryReader { geometry in
            HStack {
                PhotosView(photos: photos)
            }
            .frame(width: geometry.size.width * 0.95, height: 300)
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .overlay(RoundedRectangle(cornerRadius: 5).stroke(lineWidth: 2).foregroundColor(.gray))
            .offset(x: 10)
        }
    }
}
