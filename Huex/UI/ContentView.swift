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
	
	@State private var navState = NavigationState()
	@State private var isPermissionSheetShown = false
	
	// TODO: Bottom padding for the sheet
	// TODO: Select
	var body: some View {
		NavigationStack {
			GalleryView()
				.environment(navState)
				.navigationDestination(item: $navState.photoDetailRequest) { request in
					PhotoDetailView(
						photoMetadatas: request.photoMetadatas,
						initialPhotoID: request.id,
						namespace: request.namespace,
						gridScrollPosition: request.scrollPosition
					)
				}
				.navigationDestination(item: $navState.paletteDetailRequest) { bucket in
					CollectionDetailView()
				}
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
