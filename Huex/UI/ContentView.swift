//
//  ContentView.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 16/07/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
	@Environment(PhotoPermissionService.self) private var photoPermissionService
	
	@State private var isPermissionSheetShown = false
	
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
			isPermissionSheetShown = photoPermissionService.shouldShowPermissionSheet
		}
		.onChange(of: photoPermissionService.shouldShowPermissionSheet) { _, _ in
			isPermissionSheetShown = photoPermissionService.shouldShowPermissionSheet
		}
	}
}

#Preview {
	ContentView()
		.modelContainer(PreviewData.container)
		.environment(PhotoPermissionService(isPreview: true))
}
