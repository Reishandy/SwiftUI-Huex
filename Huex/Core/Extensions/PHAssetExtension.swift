//
//  PHAssetExtension.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 21/07/26.
//

import Photos

extension PHAsset: @retroactive Identifiable {
	public var id: String {
		self.localIdentifier
	}
}
