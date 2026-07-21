//
//  SelectionToolbar.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 21/07/26.
//

import SwiftUI

struct SelectionToolbar: ToolbarContent {
	@Binding var isSelect: Bool
	@Binding var selectedPhotos: Set<PhotoMetadata>
	
	let shouldShowSelect: Bool
	let onSelectAll: () -> Void
	let onDelete: () -> Void
	let onReanalyze: () -> Void
	let onMove: (ColorBucket) -> Void
	
	var body: some ToolbarContent {
		if isSelect {
			ToolbarItem(placement: .topBarTrailing) {
				Menu {
					Button("Select All", systemImage: "square.grid.2x2.fill") {
						withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
							onSelectAll()
						}
					}
					.disabled(!selectedPhotos.isEmpty)
					
					Button("Select None", systemImage: "square.grid.2x2") {
						withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
							selectedPhotos.removeAll()
						}
					}
					.disabled(selectedPhotos.isEmpty)
					
					Divider()
					
					Button("Reanalyze", systemImage: "arrow.2.squarepath") {
						onReanalyze()
					}
					.disabled(selectedPhotos.isEmpty)
					
					Button("Delete", systemImage: "trash", role: .destructive) {
						onDelete()
					}
					.disabled(selectedPhotos.isEmpty)
				} label: {
					Image(systemName: "ellipsis")
				}
			}
		}
		
		ToolbarSpacer(placement: .topBarTrailing)
		
		if shouldShowSelect {
			ToolbarItem(placement: .topBarTrailing) {
				if isSelect {
					Button("Done", systemImage: "checkmark") {
						withAnimation {
							isSelect = false
						}
						selectedPhotos.removeAll()
					}
					.buttonStyle(.glassProminent)
				} else {
					Button("Select") {
						withAnimation {
							isSelect = true
						}
					}
				}
			}
		}
		
		if isSelect {
			ToolbarItem(placement: .bottomBar) {
				// TODO: Share
				Button("Share", systemImage: "square.and.arrow.up") {
					
				}
				.disabled(selectedPhotos.isEmpty)
			}
			
			ToolbarSpacer(placement: .bottomBar)
			
			ToolbarItem(placement: .bottomBar) {
				Text("\(selectedPhotos.count) Photo\(selectedPhotos.count > 1 ? "s" : "") Selected")
					.bold()
					.fixedSize()
			}
			.sharedBackgroundVisibility(.hidden)
			
			ToolbarSpacer(placement: .bottomBar)
			
			ToolbarItem(placement: .bottomBar) {
				MoveMenuView(isReverse: true) { colorBucket in
					onMove(colorBucket)
				}
				.disabled(selectedPhotos.isEmpty)
			}
		}
	}
}

#Preview {
	NavigationStack {
		Text("View")
			.toolbar {
				SelectionToolbar(
					isSelect: .constant(true),
					selectedPhotos: .constant([PhotoMetadata(phaccessLocalIdentifier: "")]),
					shouldShowSelect: true,
					onSelectAll: {},
					onDelete: {},
					onReanalyze: {},
					onMove: { _ in }
				)
			}
	}
}
