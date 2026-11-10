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
	@Environment(PhotoStoreManager.self) private var photoStoreManager
	
	@State private var isSheetShown = false
	
	private var shouldShowSheet: Bool {
		photoPermissionManager.shouldShowPermissionSheet || photoStoreManager.isICloudEnabled == nil
	}
	
	var body: some View {
		NavigationStack {
			GalleryView()
		}
		.sheet(isPresented: $isSheetShown) {
			Group {
				if photoPermissionManager.isAuthorized {
					ICloudSheetView()
				} else {
					PermissionSheetView()
				}
			}
				.presentationDetents([.large])
				.interactiveDismissDisabled()
				.presentationSizing(.page)
		}
		.onAppear {
			isSheetShown = shouldShowSheet
		}
		.onChange(of: shouldShowSheet) { _, _ in
			isSheetShown = shouldShowSheet
		}
	}
}

#Preview {
	ContentView()
		.modelContainer(PreviewData.container)
		.environment(PhotoPermissionManager(isPreview: true))
		.environment(PhotoStoreManager())
}
