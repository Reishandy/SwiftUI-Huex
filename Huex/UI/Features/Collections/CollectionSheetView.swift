//
//  CollectionSheetView.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 19/07/26.
//

import SwiftUI
import SwiftData

struct CollectionSheetView: View {
	@Environment(NavigationState.self) private var navState
	@Environment(\.dismiss) private var dismiss
	
	var body: some View {
		List {
			ForEach(ColorBucket.allCases) { bucket in
				Button {
					dismiss()
					navState.paletteDetailRequest = bucket
				} label: {
					CollectionItemView(colorBucket: bucket)
				}
			}
			.padding(.top, 10)
		}
		.listStyle(.plain)
	}
}

#Preview {
	CollectionSheetView()
		.environment(NavigationState())
		.modelContainer(PreviewData.container)
}
