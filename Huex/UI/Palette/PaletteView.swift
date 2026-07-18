//
//  PaletteView.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 16/07/26.
//

import SwiftUI

struct PaletteView: View {
    var body: some View {
		// TODO: View
		NavigationStack {
			Text("Palette View")
				.toolbar {
					ToolbarItem(placement: .topBarLeading) {
						TitleView(titleName: "Palette")
					}
					.sharedBackgroundVisibility(.hidden)
					
					ToolbarItem(placement: .topBarTrailing) {
						// TODO: Actions
						Image(systemName: "ellipsis")
					}
				}
		}
    }
}

#Preview {
    PaletteView()
}
