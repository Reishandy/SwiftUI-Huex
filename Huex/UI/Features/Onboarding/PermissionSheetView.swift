//
//  PermissionSheetView.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 17/07/26.
//

import SwiftUI

struct PermissionSheetView: View {
	@Environment(PhotoPermissionManager.self) private var photoPermissionManager
	
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
			
			Text("To automatically organize your gallery into beautiful, color-coordinated collections, Huex needs access to your photo library.")
				.multilineTextAlignment(.center)
				.foregroundStyle(.secondary)
				.padding(.horizontal)
			
			Spacer()
			
			Text("For your privacy, all color analysis is processed entirely on your device. Processing a large gallery may take a few minutes, and some tiny color details might be playfully approximated! Huex will try its best to categorize your photos!")
				.multilineTextAlignment(.center)
				.font(.footnote)
				.foregroundStyle(.secondary)
				.padding(.horizontal)
			
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
