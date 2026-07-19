//
//  CollectionSheetView.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 19/07/26.
//

import SwiftUI

struct CollectionSheetView: View {
	@Environment(NavigationState.self) private var navState
	
	// TODO: View
	var body: some View {
		List {
			ForEach(ColorBucket.allCases) { bucket in
				Button {
					navState.paletteDetailRequest = bucket
				} label: {
					Text(bucket.displayName)
				}
			}
		}
	}
}

#Preview {
	CollectionSheetView()
		.environment(NavigationState())
}
