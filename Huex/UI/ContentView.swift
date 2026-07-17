//
//  ContentView.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 16/07/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
		TabView {
			Tab("Gallery", systemImage: "photo.on.rectangle.angled.fill") {
				GalleryView()
			}
			
			Tab("Palette", systemImage: "swatchpalette.fill") {
				PaletteView()
			}
			
			Tab("Search", systemImage: "magnifyingglass", role: .search) {
				SearchView()
			}
		}
		.tabViewStyle(.sidebarAdaptable)
    }
}

#Preview {
    ContentView()
		.modelContainer(PreviewData.container)
}
