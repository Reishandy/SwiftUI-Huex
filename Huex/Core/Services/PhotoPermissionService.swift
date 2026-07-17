//
//  PhotoPermissionService.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 17/07/26.
//

import Foundation
import Photos
import Observation

@Observable
@MainActor
final class PhotoPermissionService {
	private(set) var authorizationStatus: PHAuthorizationStatus
	
	init(isPreview: Bool = false) {
		self.authorizationStatus = isPreview ? .authorized : PHPhotoLibrary.authorizationStatus(for: .readWrite)
	}
	
	var isAuthorized: Bool {
		authorizationStatus == .authorized || authorizationStatus == .limited
	}
	
	var shouldShowPermissionSheet: Bool {
		authorizationStatus == .denied || authorizationStatus == .restricted || authorizationStatus == .notDetermined
	}
	
	var hasAlreadyGivenPermission: Bool {
		authorizationStatus != .notDetermined
	}
	
	func requestAccess() async {
		guard authorizationStatus == .notDetermined else { return }
		authorizationStatus = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
	}
	
	func refreshStatus() {
		let current = PHPhotoLibrary.authorizationStatus(for: .readWrite)
		guard current != authorizationStatus else { return }
		authorizationStatus = current
	}
}
