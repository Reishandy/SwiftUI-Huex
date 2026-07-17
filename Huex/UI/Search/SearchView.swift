//
//  SearchView.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 16/07/26.
//

import SwiftUI

struct SearchView: View {
    var body: some View {
		// TODO: View
		NavigationStack {
			Text("Search View")
				.toolbar {
					ToolbarItem(placement: .topBarLeading) {
						TitleView(titleName: "Search")
					}
					.sharedBackgroundVisibility(.hidden)
				}
		}
    }
}

#Preview {
    SearchView()
}
