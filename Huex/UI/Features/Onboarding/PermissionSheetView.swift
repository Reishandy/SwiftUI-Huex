//
//  PermissionSheetView.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 17/07/26.
//

import SwiftUI

struct PermissionSheetView: View {
	@Environment(PhotoPermissionManager.self) private var photoPermissionManager
	
	// TODO: Improve more playful wording
	var body: some View {
		VStack(spacing: 24) {
			Spacer()
			
			Image(systemName: "photo.on.rectangle.angled")
				.resizable()
				.scaledToFit()
				.frame(width: 100, height: 100)
				.foregroundStyle(
					LinearGradient(
						colors: [.blue, .purple, .pink, .orange],
						startPoint: .topLeading,
						endPoint: .bottomTrailing
					)
				)
			
			Text("Permission Request")
				.font(.largeTitle)
				.fontWeight(.bold)
			
			VStack(spacing: 12) {
				Text("To automatically organize your gallery into beautiful, color-coordinated collections, Huex needs access to your photo library.")
					.fontWeight(.semibold)
				
				Text("All color analysis is processed securely on your device.")
			}
			.font(.body)
			.multilineTextAlignment(.center)
			.foregroundStyle(.secondary)
			.padding(.horizontal)
			
			Spacer()
			
			Button {
				if photoPermissionManager.hasAlreadyGivenPermission {
					if let url = URL(string: UIApplication.openSettingsURLString) {
						UIApplication.shared.open(url)
					}
				} else {
					Task {
						await photoPermissionManager.requestAccess()
					}
				}
			} label: {
				Group {
					if photoPermissionManager.hasAlreadyGivenPermission {
						Text("Open Settings")
					} else {
						Text("Continue")
					}
				}
				.bold()
				.frame(maxWidth: .infinity)
			}
			.buttonStyle(.borderedProminent)
			.controlSize(.large)
			.padding(.bottom, 8)
		}
		.padding()
	}
}

#Preview {
	Text("Parent View")
		.sheet(isPresented: .constant(true)) {
			PermissionSheetView()
				.presentationDetents([.large])
				.interactiveDismissDisabled()
				.environment(PhotoPermissionManager())
		}
}
