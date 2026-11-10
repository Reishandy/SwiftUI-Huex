//
//  ICloudSheetView.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 11/11/26.
//

import SwiftUI

struct ICloudSheetView: View {
	@Environment(\.dismiss) private var dismiss
	@Environment(PhotoStoreManager.self) private var photoStoreManager
	
	var body: some View {
		VStack(spacing: 24) {
			Spacer()
			
			Image(systemName: "icloud.and.arrow.down")
				.resizable()
				.scaledToFit()
				.frame(width: 100, height: 100)
				.foregroundStyle(
					LinearGradient(
						colors: [.blue, .cyan],
						startPoint: .bottomTrailing,
						endPoint: .topLeading
					)
				)
			
			Text("iCloud Photos")
				.font(.largeTitle)
				.fontWeight(.bold)
			
			Text("Photos stored in iCloud must be downloaded before Huex can read their colors. Without this, only photos available on your device are analyzed.")
				.multilineTextAlignment(.center)
				.foregroundStyle(.secondary)
				.padding(.horizontal)
			
			Spacer()
			
			Text("Enabling this can heavily impact performance, battery life and data usage, especially with a large library. You can change this anytime from the menu in the gallery.")
				.multilineTextAlignment(.center)
				.font(.footnote)
				.foregroundStyle(.secondary)
				.padding(.horizontal)
			
			VStack(spacing: 12) {
				Button {
					choose(true)
				} label: {
					Text("Enable iCloud Photos")
						.bold()
						.frame(maxWidth: .infinity)
				}
				.buttonStyle(.borderedProminent)
				
				Button {
					choose(false)
				} label: {
					Text("Use On-Device Photos Only")
						.bold()
						.frame(maxWidth: .infinity)
				}
				.buttonStyle(.bordered)
			}
			.controlSize(.large)
			.padding(.bottom, 8)
		}
		.padding()
	}
	
	private func choose(_ isEnabled: Bool) {
		Task {
			await photoStoreManager.setICloudEnabled(isEnabled)
		}
		dismiss()
	}
}

#Preview {
	Text("Parent View")
		.sheet(isPresented: .constant(true)) {
			ICloudSheetView()
				.presentationDetents([.large])
				.environment(PhotoStoreManager())
		}
}
