//
//  PhotoDetailRequest.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 19/07/26.
//

import SwiftUI

struct PhotoDetailRequest: Identifiable, Hashable {
	let id: PhotoMetadata.ID
	let photoMetadatas: [PhotoMetadata]
	let namespace: Namespace.ID
	let scrollPosition: Binding<ScrollPosition>
	
	static func == (lhs: Self, rhs: Self) -> Bool {
		lhs.id == rhs.id
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}
