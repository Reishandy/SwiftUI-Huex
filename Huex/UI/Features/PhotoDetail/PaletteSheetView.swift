//
//  PaletteSheetView.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 19/07/26.
//

import SwiftUI

struct PaletteSheetView: View {
	let photoMetadata: PhotoMetadata
	let isExpanded: Bool
	
	var navTitle: String {
		if !photoMetadata.swatches.isEmpty {
			return "\(photoMetadata.swatches.count) color\(photoMetadata.swatches.count > 1 ? "s" : "")"
		} else {
			return "Color Palette"
		}
	}
	
	var body: some View {
		NavigationStack {
			Group {
				if photoMetadata.swatches.isEmpty {
					EmptyStateView(
						systemImage: "swatchpalette",
						title: "No Palette Yet",
						description: "Please wait for the analysis process to complete"
					)
				} else {
					ScrollView {
						PaletteStripView(swatches: photoMetadata.swatches)
							.padding(.horizontal, 30)
						
						ForEach(photoMetadata.swatches.sorted { $0.weight > $1.weight }) { swatch in
							PaletteItemView(swatch: swatch, isExpanded: isExpanded)
						}
						.padding(.horizontal, 20)
					}
				}
			}
			.navigationTitle(navTitle)
			.navigationBarTitleDisplayMode(.inline)
		}
	}
}

#Preview {
	@Previewable @State var sheetDetent: PresentationDetent = .medium
	
	Text("View")
		.sheet(isPresented: .constant(true)) {
			PaletteSheetView(
				photoMetadata: PhotoMetadata(
					phaccessLocalIdentifier: "preview",
					swatches: PreviewData.sampleSwatches
				),
				isExpanded: sheetDetent == .large
			)
			.presentationDetents([.medium, .large], selection: $sheetDetent)
		}
}
