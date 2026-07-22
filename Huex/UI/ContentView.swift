//
//  ContentView.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 16/07/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
	@Environment(PhotoPermissionManager.self) private var photoPermissionManager
	
	@State private var isPermissionSheetShown = false
	
	// TODO: Select with drag
	// TODO: fix when analyzing the move list on both gallary and detail is pulsing with the progress
	var body: some View {
		NavigationStack {
			GalleryView()
		}
		.sheet(isPresented: $isPermissionSheetShown) {
			PermissionSheetView()
				.presentationDetents([.large])
				.interactiveDismissDisabled()
				.presentationSizing(.page)
		}
		.onAppear {
			isPermissionSheetShown = photoPermissionManager.shouldShowPermissionSheet
		}
		.onChange(of: photoPermissionManager.shouldShowPermissionSheet) { _, _ in
			isPermissionSheetShown = photoPermissionManager.shouldShowPermissionSheet
		}
	}
}

#Preview {
	ContentView()
		.modelContainer(PreviewData.container)
		.environment(PhotoPermissionManager(isPreview: true))
		.environment(PhotoStoreManager())
}
