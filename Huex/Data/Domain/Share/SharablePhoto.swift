//
//  SharablePhoto.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 23/07/26.
//

import SwiftUI
import Photos

struct SharablePhoto: Identifiable, Transferable {
	let id: String
	let mode: ShareMode
	let bucketDisplayName: String
	let bucketSymbol: String
	let bucketColor: Color
	let swatches: [Swatch]
	
	static var transferRepresentation: some TransferRepresentation {
		DataRepresentation(exportedContentType: .png) { item in
			let uiImage = await item.renderAsImage()
			return uiImage?.pngData() ?? Data()
		}
	}
	
	@MainActor
	func renderAsImage() async -> UIImage? {
		guard let asset = fetchPHassets(localIdentifiers: [id]).first else { return nil }
		let sourceImage = await fetchImage(asset: asset, targetSize: CGSize(width: 1600, height: 1600))
		let card = ShareItemView(image: sourceImage, bucketDisplayName: bucketDisplayName, bucketSymbol: bucketSymbol, bucketColor: bucketColor, swatches: swatches, shareMode: mode)
			.frame(width: 800)
		let renderer = ImageRenderer(content: card)
		renderer.scale = 3.0
		return renderer.uiImage
	}
}
