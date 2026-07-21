//
//  CollectionSheetView.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 19/07/26.
//

import SwiftUI
import SwiftData

struct CollectionSheetView: View {
	@Environment(\.dismiss) private var dismiss
	@Binding var selectedBucket: ColorBucket?
	
	var body: some View {
		List {
			ForEach(ColorBucket.allCases) { bucket in
				Button {
					dismiss()
					selectedBucket = bucket
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
	CollectionSheetView(selectedBucket: .constant(.red))
		.modelContainer(PreviewData.container)
}
