//
//  PreviewData.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 17/07/26.
//

import SwiftUI
import SwiftData
import simd

enum PreviewData {
	@MainActor
	static var container: ModelContainer = {
		let config = ModelConfiguration(isStoredInMemoryOnly: true)
		let container = try! ModelContainer(for: PhotoMetadata.self, configurations: config)
		
		let sampleIDs = (1...999).map { "Preview-\($0)" }
		
		for id in sampleIDs {
			var swatches: [Swatch]? = nil
			var bucket: ColorBucket? = nil
			var analyzedDate: Date? = nil
			
			analyzedDate = Date().addingTimeInterval(-Double.random(in: 0...604800))
			bucket = ColorBucket.allCases.randomElement()!
			
			let numSwatches = Int.random(in: 2...10)
			var generatedSwatches: [Swatch] = []
			var totalWeight: Double = 0
			
			for _ in 0..<numSwatches {
				let randomHex = String(format: "#%06X", Int.random(in: 0...0xFFFFFF))
				
				let rawWeight = Double.random(in: 0.1...1.0)
				totalWeight += rawWeight
				
				let swatch = Swatch.make(
					hex: randomHex,
					weight: rawWeight
				)
				
				generatedSwatches.append(swatch)
			}
			
			swatches = generatedSwatches.map { swatch in
				var normalized = swatch
				normalized.weight = swatch.weight / totalWeight
				return normalized
			}
			
			swatches?.sort { $0.weight > $1.weight }
			
			let metadata = PhotoMetadata(
				phaccessLocalIdentifier: id,
				anayzedDate: analyzedDate,
				swatches: swatches,
				bucket: bucket
			)
			
			container.mainContext.insert(metadata)
		}
		
		return container
	}()
	
	static let sampleSwatches: [Swatch] = [
		.make(hex: "#FF3B30", weight: 0.30),
		.make(hex: "#FF9500", weight: 0.20),
		.make(hex: "#FFCC00", weight: 0.15),
		.make(hex: "#34C759", weight: 0.15),
		.make(hex: "#007AFF", weight: 0.10),
		.make(hex: "#AF52DE", weight: 0.10)
	]
}
