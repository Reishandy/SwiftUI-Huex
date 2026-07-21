//
//  MoveMenuView.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 21/07/26.
//

import SwiftUI

struct MoveMenuView: View {
	var isReverse: Bool = false
	let onMove: (ColorBucket) -> Void
	
    var body: some View {
		Menu {
			ForEach(isReverse ? ColorBucket.allCases.reversed() : ColorBucket.allCases) { colorBucket in
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
