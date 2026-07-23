//
//  DetailMenuView.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 23/07/26.
//

import SwiftUI

struct DetailMenuView: View, Equatable {
	let bucket: ColorBucket?
	let onMove: (ColorBucket) -> Void
	let onReanalyze: () -> Void
	let onDelete: () -> Void
	
	static func == (lhs: DetailMenuView, rhs: DetailMenuView) -> Bool {
		return lhs.bucket == rhs.bucket
	}
	
	var body: some View {
		Menu {
			MoveMenuView { colorBucket in
				onMove(colorBucket)
			}
			Button("Reanalyze", systemImage: "arrow.2.squarepath") {
				onReanalyze()
			}
			Button("Delete", systemImage: "trash", role: .destructive) {
				onDelete()
			}
		} label: {
			Image(systemName: "ellipsis")
		}
	}
}
