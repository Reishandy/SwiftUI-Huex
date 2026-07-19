//
//  NavigationState.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 19/07/26.
//

import Observation

@Observable
final class NavigationState {
	var photoDetailRequest: PhotoDetailRequest?
	var paletteDetailRequest: ColorBucket? // TODO: Pass the metadatas
}
