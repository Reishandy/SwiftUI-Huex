//
//  PhotoDetailView.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 16/07/26.
//

import SwiftUI

struct PhotoDetailView: View {
	@Environment(\.dismiss) private var dismiss
	
	// TODO: Swipeable photos
    var body: some View {
		NavigationStack {
			// TODO: View
			Text("Photo Detail View")
				.toolbar {
					ToolbarItem(placement: .topBarLeading) {
						Button {
							dismiss()
						} label: {
							Image(systemName: "chevron.backward")
						}
					}
				}
		}
    }
}

#Preview {
    PhotoDetailView()
}
