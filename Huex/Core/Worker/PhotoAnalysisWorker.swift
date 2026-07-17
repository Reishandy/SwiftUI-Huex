//
//  PhotoAnalysisWorker.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 17/07/26.
//

import Foundation
import Photos
import SwiftData

@ModelActor
actor PhotoAnalysisWorker {
	private var isRunning = false
	private var needsAnotherPass = false
	
	func run() async {
		if isRunning {
			needsAnotherPass = true
			return
		}
		
		isRunning = true
		defer { isRunning = false }
		
		repeat {
			needsAnotherPass = false
			await runSinglePass()
		} while needsAnotherPass
	}
	
	private func runSinglePass() async {
		// TODO: once PhotoMetadata has a category / isAnalyzed attribute, filter
		// this fetch down to only unanalyzed rows (like the old #Predicate against
		// categoryRawValue == uncategorized). For now, this just pulls everything.
		let allMetadata: [PhotoMetadata]
		do {
			allMetadata = try modelContext.fetch(FetchDescriptor<PhotoMetadata>())
		} catch {
			print("> PhotoAnalysisWorker: failed to fetch metadata: \(error)")
			return
		}
		
		for metadata in allMetadata {
			_ = await analyzePhoto(phaccessLocalIdentifier: metadata.phaccessLocalIdentifier)
			
			// TODO: once analyzePhoto returns real results, write them back:
			// metadata.category = result.category
			// metadata.colorPaletteHex = result.colorPaletteHex
			// try? modelContext.save()
		}
	}
}

private func analyzePhoto(phaccessLocalIdentifier: String) async -> Void {
	// TODO: implement real analysis (color bucketing, categorization, etc.)
	print("> Would analyze: \(phaccessLocalIdentifier)")
}
