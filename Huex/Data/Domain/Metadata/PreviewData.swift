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
		
		let mockColors = [
			("#FF3B30", "Red"), ("#FF9500", "Orange"), ("#FFCC00", "Yellow"),
			("#34C759", "Green"), ("#007AFF", "Blue"), ("#AF52DE", "Purple"),
			("#1C1C1E", "Black"), ("#F2F2F7", "White"), ("#8E8E93", "Gray")
		]
		
		let sampleIDs = (1...999).map { "Preview-\($0)" }
		
		for id in sampleIDs {
			var swatches: [Swatch]? = nil
			var bucket: ColorBucket? = nil
			var confidence: Double = 0.0
			var analyzedDate: Date? = nil
			
			analyzedDate = Date().addingTimeInterval(-Double.random(in: 0...604800))
			
			bucket = ColorBucket.allCases.randomElement()!
			
			confidence = Double.random(in: 0.4...1.0)
			
			let numSwatches = Int.random(in: 1...5)
			var generatedSwatches: [Swatch] = []
			var totalWeight: Double = 0
			
			for _ in 0..<numSwatches {
				let randomColor = mockColors.randomElement()!
				let hexString = randomColor.0
				let name = randomColor.1
				
				let rawWeight = Double.random(in: 0.1...1.0)
				totalWeight += rawWeight
				
				let rgbTuple = hexToRGB(hexString)
				
				let rgbSimd = simd_float3(Float(rgbTuple.r), Float(rgbTuple.g), Float(rgbTuple.b))
				
				let labSimd = rgbToLab(rgbSimd)
				let lchColor = labToLCh(labSimd)
				
				let labColor = LabColor(
					l: Double(labSimd.x),
					a: Double(labSimd.y),
					b: Double(labSimd.z)
				)
				
				generatedSwatches.append(Swatch(
					hex: hexString,
					lab: labColor,
					lch: lchColor,
					weight: rawWeight,
					name: name
				))
			}
			
			swatches = generatedSwatches.map { swatch in
				var normalized = swatch
				normalized.weight = swatch.weight / totalWeight
				return normalized
			}
			
			let metadata = PhotoMetadata(
				phaccessLocalIdentifier: id,
				anayzedDate: analyzedDate,
				swatches: swatches,
				bucket: bucket,
				confidence: confidence
			)
			
			container.mainContext.insert(metadata)
		}
		
		return container
	}()
}
