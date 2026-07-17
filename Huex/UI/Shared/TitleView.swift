//
//  TitleView.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 16/07/26.
//

import SwiftUI

struct TitleView: View {
	let titleName: String
	var totalImages: Int? = nil
	var processedImages: Int? = nil
	var isProcessing: Bool? = nil
	
	var body: some View {
		VStack(alignment: .leading) {
			Text(titleName)
				.font(.largeTitle)
				.bold()
				.fixedSize()
			
			if let totalImages = totalImages,
			   let processedImages = processedImages,
			   let isProcessing = isProcessing {
				HStack {
					Text(isProcessing ? "Categorizing \(processedImages)/\(totalImages)" : "\(totalImages) Images")
						.foregroundStyle(.secondary)
						.fixedSize()
						.contentTransition(.interpolate)
					
					if isProcessing {
						Image(systemName: "square.grid.2x2")
							.foregroundStyle(.secondary)
							.font(.caption)
							.symbolEffect(.bounce.down, options: .repeat(.periodic(delay: 0.5)))
							.transition(.opacity.combined(with: .scale))
					}
				}
				.animation(.easeInOut, value: isProcessing)
			} else {
				Text(" ")
					.hidden()
			}
		}
		.padding(.top)
	}
}

#Preview {
	NavigationStack {
		Text("View")
			.toolbar {
				ToolbarItem(placement: .topBarLeading) {
					TitleView(
						titleName: "Gallery",
						totalImages: 4321,
						processedImages: 432,
						isProcessing: false
					)
				}
				.sharedBackgroundVisibility(.hidden)
				
				ToolbarItem(placement: .topBarTrailing) {
					Image(systemName: "plus")
				}
			}
	}
}
