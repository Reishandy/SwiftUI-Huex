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
	
	// TODO: Other attributes
	
	init(phaccessLocalIdentifier: String) {
		self.phaccessLocalIdentifier = phaccessLocalIdentifier
		self.timestamp = .now
	}
}
