//
//  PhotoAlertModifier.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 21/07/26.
//

import SwiftUI

struct PhotoAlertModifier: ViewModifier {
	let selectedCount: Int
	@Binding var showDeleteAlert: Bool
	@Binding var showReanalyzeAlert: Bool
	@Binding var moveToBucket: ColorBucket?
	
	let onDelete: () -> Void
	let onReanalyze: () -> Void
	let onMove: () -> Void
	
	func body(content: Content) -> some View {
		content
			.alert("Delete Photo?", isPresented: $showDeleteAlert) {
				Button("Cancel", role: .cancel) { }
				Button("Delete", role: .destructive) {
					onDelete()
				}
			} message: {
				Text("\(selectedCount > 1 ? "\(selectedCount) Photos" : "This Photo") will be moved to \"Recently Deleted\", are you sure you want to proceed?")
			}
			.alert("Reanalyze Photo?", isPresented: $showReanalyzeAlert) {
				Button("Cancel", role: .cancel) { }
				Button("Reanalyze") {
					onReanalyze()
				}
			} message: {
				Text("Are you sure you want to reanalyze \(selectedCount > 1 ? "\(selectedCount) photos" : "this photo")? The color palette and category will be reanalyzed (any manual categorizing will be reset).")
			}
			.alert(
				"Move Photo?",
				isPresented: Binding(
					get: { moveToBucket != nil },
					set: { if !$0 { moveToBucket = nil } }
				),
				presenting: moveToBucket
			) { bucket in
				Button("Cancel", role: .cancel) { }
				Button("Move") {
					onMove()
				}
			} message: { bucket in
				Text("Are you sure you want to move \(selectedCount > 1 ? "\(selectedCount) photos" : "this photo") to \(bucket.displayName) collections?")
			}
	}
}

extension View {
	func photoActionAlerts(
		selectedCount: Int,
		showDeleteAlert: Binding<Bool>,
		showReanalyzeAlert: Binding<Bool>,
		moveToBucket: Binding<ColorBucket?>,
		onDelete: @escaping () -> Void,
		onReanalyze: @escaping () -> Void,
		onMove: @escaping () -> Void
	) -> some View {
		modifier(PhotoAlertModifier(
			selectedCount: selectedCount,
			showDeleteAlert: showDeleteAlert,
			showReanalyzeAlert: showReanalyzeAlert,
			moveToBucket: moveToBucket,
			onDelete: onDelete,
			onReanalyze: onReanalyze,
			onMove: onMove
		))
	}
}
