//
//  EmpyStateView.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 19/07/26.
//

import SwiftUI

struct EmpyStateView: View {
	var systemImage: String
	var title: String
	var description: String
	
	var body: some View {
		VStack(spacing: 24) {
			Image(systemName: systemImage)
				.font(.custom("iconExtraLarge", size: 70))
				.foregroundStyle(.secondary)
			
			VStack(spacing: 10) {
				Text(title)
					.font(.title2)
					.bold()
					.multilineTextAlignment(.center)
				
				Text(description)
					.foregroundStyle(.secondary)
					.multilineTextAlignment(.center)
			}
		}
		.padding()
	}
}

#Preview {
    EmpyStateView(systemImage: "questionmark", title: "Empty", description: "Nothing")
}
