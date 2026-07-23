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
	
	@State private var displayMode: PaletteDisplayMode = .palette
	
	private var displayedSwatches: [Swatch] {
		switch displayMode {
		case .palette: photoMetadata.topPalette
		case .all: photoMetadata.swatches.sorted { $0.weight > $1.weight }
		}
	}
	
	var body: some View {
		NavigationStack {
			if photoMetadata.swatches.isEmpty {
				EmptyStateView(
					systemImage: "swatchpalette",
					title: "No Palette Yet",
					description: "Please wait for the analysis process to complete"
				)
			} else {
				ScrollView {
					PaletteStripView(swatches: photoMetadata.swatches)
						.padding(.horizontal, 25)
					
					ForEach(displayedSwatches.sorted { $0.weight > $1.weight }) { swatch in
						PaletteItemView(swatch: swatch, isExpanded: isExpanded)
					}
					.padding(.horizontal, 15)
				}
				.navigationTitle(displayMode == .palette ? "Color Palette" : "All Colors")
				.navigationBarTitleDisplayMode(.inline)
				.toolbar {
					ToolbarItem(placement: .topBarTrailing) {
						Menu {
							Picker("Color Mode", selection: $displayMode) {
								ForEach(PaletteDisplayMode.allCases) { mode in
									Text(mode.rawValue).tag(mode)
								}
								.labelsVisibility(.visible)
							}
						} label: {
							Image(systemName: "line.3.horizontal.decrease")
						}
					}
				}
				.animation(.default, value: displayMode)
			}
		}
	}
}

enum PaletteDisplayMode: String, CaseIterable, Identifiable {
	var id: Self { self }
	
	case palette = "Palette"
	case all = "All"
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
