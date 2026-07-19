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
	
	@State private var photoPermissionService = PhotoPermissionService()
	@State private var photoSyncService: PhotoSyncService
	
	@Environment(\.scenePhase) private var scenePhase
	
	init() {
		do {
			modelContainer = try ModelContainer(for: PhotoMetadata.self)
		} catch {
			fatalError("Failed to initialize SwiftData: \(error)")
		}
		
		_photoSyncService = State(initialValue: PhotoSyncService(modelContainer: modelContainer))
	}
	
	// TODO: Cloudkit sync
	var body: some Scene {
		WindowGroup {
			ContentView()
				.environment(photoPermissionService)
				.environment(photoSyncService)
				.task(id: photoPermissionService.authorizationStatus) {
					guard photoPermissionService.isAuthorized else { return }
					await photoSyncService.start()
				}
		}
		.modelContainer(modelContainer)
		.onChange(of: scenePhase) { _, newPhase in
			guard newPhase == .active else { return }
			photoPermissionService.refreshStatus()
		}
	}
}
