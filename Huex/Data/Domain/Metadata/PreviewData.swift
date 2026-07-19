//
//  PreviewData.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 17/07/26.
//

import SwiftData

enum PreviewData {
	@MainActor
	static var container: ModelContainer = {
		let config = ModelConfiguration(isStoredInMemoryOnly: true)
		let container = try! ModelContainer(for: PhotoMetadata.self, configurations: config)
		
		let sampleIDs = (1...99).map { "Preview-\($0)" }
		for id in sampleIDs {
			container.mainContext.insert(PhotoMetadata(phaccessLocalIdentifier: id))
		}
		
		return container
	}()
}
