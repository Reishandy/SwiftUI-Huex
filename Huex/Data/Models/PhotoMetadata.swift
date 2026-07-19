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
	var bucket: ColorBucket?
	var confidence: Double
	
	init(phaccessLocalIdentifier: String) {
		self.phaccessLocalIdentifier = phaccessLocalIdentifier
		self.timestamp = .now
		self.analyzedDate = nil
		self.swatches = nil
		self.bucket = nil
		self.confidence = 0
	}
}
