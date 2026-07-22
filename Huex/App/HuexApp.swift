//
//  HuexApp.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 16/07/26.
//

import SwiftUI
import SwiftData

@main
struct HuexApp: App {
	private let modelContainer: ModelContainer
	
	@State private var photoPermissionManager = PhotoPermissionManager()
	@State private var photoStoreManager: PhotoStoreManager
	
	@Environment(\.scenePhase) private var scenePhase
	
	init() {
		do {
			modelContainer = try ModelContainer(for: PhotoMetadata.self)
		} catch {
			fatalError("Failed to initialize SwiftData: \(error)")
		}
		
		_photoStoreManager = State(initialValue: PhotoStoreManager(modelContainer: modelContainer))
	}
	
	var body: some Scene {
		WindowGroup {
			ContentView()
				.environment(photoPermissionManager)
				.environment(photoStoreManager)
				.task(id: photoPermissionManager.authorizationStatus) {
					guard photoPermissionManager.isAuthorized else { return }
					await photoStoreManager.start()
				}
		}
		.modelContainer(modelContainer)
		.onChange(of: scenePhase) { _, newPhase in
			guard newPhase == .active else { return }
			photoPermissionManager.refreshStatus()
		}
	}
}
