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
	let topPalette: [Swatch]
	let metadataScale: CGFloat
	
	static var transferRepresentation: some TransferRepresentation {
		DataRepresentation(exportedContentType: .jpeg) { item in
			if item.mode == .clean {
				return await item.fetchOriginalImageData() ?? Data()
			} else {
				let uiImage = await item.renderAsImage()
				return uiImage?.jpegData(compressionQuality: 1.0) ?? Data()
			}
		}
	}
	
	@MainActor
	func fetchOriginalImageData() async -> Data? {
		guard let asset = fetchPHassets(localIdentifiers: [id]).first else { return nil }
		
		return await withCheckedContinuation { continuation in
			let options = PHImageRequestOptions()
			options.isNetworkAccessAllowed = true
			options.deliveryMode = .highQualityFormat
			
			PHImageManager.default().requestImageDataAndOrientation(for: asset, options: options) { data, _, _, _ in
				continuation.resume(returning: data)
			}
		}
	}
	
	@MainActor
	func renderAsImage() async -> UIImage? {
		await ShareRenderQueue.shared.render { [self] in
			guard let asset = fetchPHassets(localIdentifiers: [id]).first else { return nil }
			
			let sourceImage = await fetchImage(asset: asset, targetSize: CGSize(width: 1600, height: 1600))
			
			let card = ShareItemView(
				image: sourceImage,
				bucketDisplayName: bucketDisplayName,
				bucketSymbol: bucketSymbol,
				bucketColor: bucketColor,
				swatches: swatches,
				topPalette: topPalette,
				shareMode: mode,
				metadataScale: metadataScale
			)
				.frame(width: 800)
			
			let renderer = ImageRenderer(content: card)
			renderer.scale = 2.0
			
			return renderer.uiImage
		}
	}
}

actor ShareRenderQueue {
	static let shared = ShareRenderQueue()
	private init() {}
	
	func render(_ work: @escaping () async -> UIImage?) async -> UIImage? {
		await work()
	}
}
