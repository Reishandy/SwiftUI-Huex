//
//  PhotoMetadata.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 17/07/26.
//

import Foundation
import SwiftUI
import SwiftData

@Model
class PhotoMetadata: Identifiable, Equatable {
	@Attribute(.unique) var phaccessLocalIdentifier: String
	var timestamp: Date
	
	@Attribute(.externalStorage) var swatchesData: Data
	var swatches: [Swatch] {
		get {
			(try? JSONDecoder().decode([Swatch].self, from: swatchesData)) ?? []
		}
		set {
			swatchesData = (try? JSONEncoder().encode(newValue)) ?? Data()
		}
	}
	
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
		swatches: [Swatch] = [],
		bucket: ColorBucket? = nil
	) {
		self.phaccessLocalIdentifier = phaccessLocalIdentifier
		self.timestamp = timestamp
		self.swatchesData = (try? JSONEncoder().encode(swatches)) ?? Data()
		self.bucketRawValue = bucket?.rawValue
	}
}
