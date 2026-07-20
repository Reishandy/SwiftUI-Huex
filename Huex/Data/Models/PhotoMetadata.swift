//
//  PhotoMetadata.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 17/07/26.
//

import SwiftUI
import SwiftData

@Model
class PhotoMetadata: Identifiable, Equatable {
	@Attribute(.unique) var phaccessLocalIdentifier: String
	var timestamp: Date
	var analyzedDate: Date?
	
	var swatches: [Swatch]?
	var confidence: Double
	
	// Cheesig the Predicate stuff here, needs it to be primitive to filter
	var bucketRawValue: String?
	var bucket: ColorBucket? {
		get {
			if let raw = bucketRawValue { return ColorBucket(rawValue: raw) }
			return nil
		}
		set { bucketRawValue = newValue?.rawValue }
	}
	
	init(
		phaccessLocalIdentifier: String,
		timestamp: Date = .now,
		anayzedDate: Date? = nil,
		swatches: [Swatch]? = nil,
		bucket: ColorBucket? = nil,
		confidence: Double = 0
	) {
		self.phaccessLocalIdentifier = phaccessLocalIdentifier
		self.timestamp = timestamp
		self.analyzedDate = anayzedDate
		self.swatches = swatches
		self.bucketRawValue = bucket?.rawValue
		self.confidence = confidence
	}
}
