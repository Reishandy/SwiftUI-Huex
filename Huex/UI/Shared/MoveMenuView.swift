//
//  MoveMenuView.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 21/07/26.
//

import SwiftUI

struct MoveMenuView: View, Equatable {
	var isReverse: Bool = false
	let onMove: (ColorBucket) -> Void
	
	static func == (lhs: MoveMenuView, rhs: MoveMenuView) -> Bool {
		return lhs.isReverse == rhs.isReverse
	}
	
	var body: some View {
		Menu {
			ForEach(isReverse ? ColorBucket.allCases.reversed() : ColorBucket.allCases, id: \.self) { colorBucket in
				Button {
					onMove(colorBucket)
				} label: {
					HStack {
						Image(systemName: colorBucket.symbol)
							.tint(colorBucket.color)
						Text(colorBucket.displayName)
					}
				}
			}
		} label: {
			Label("Move", systemImage: "arrow.forward.folder")
		}
	}
}

#Preview {
	MoveMenuView() { _ in}
}
