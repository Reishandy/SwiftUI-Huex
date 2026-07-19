//
//  FlushGridView.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 16/07/26.
//

import SwiftUI

struct FlushGridView<Item: Identifiable & Equatable, Content: View>: View {
	private let items: [Item]
	private let isReversed: Bool
	private let columnCount: Int
	private let visibleRowCount: Int
	private let spacing: CGFloat
	
	@ViewBuilder private let content: (Item) -> Content
	
	@State private var shouldPad: Bool
	
	@Binding var scrollPosition: ScrollPosition
	
	private var columns: [GridItem] {
		Array(repeating: GridItem(.flexible(), spacing: spacing), count: columnCount)
	}
	
	private var missingItems: Int {
		(columnCount - (items.count % columnCount)) % columnCount
	}
	
	private var triggerIndex: Int {
		let targetVisualIndex = isReversed ? (columnCount * 2) - 1 : (items.count - 1) - columnCount - 2
		let calculatedIndex = isReversed ? targetVisualIndex - missingItems : targetVisualIndex + missingItems
		
		return max(0, min(calculatedIndex, items.count - 1))
	}
	
	private var safeToPad: Bool {
		items.count > (columnCount * visibleRowCount) + columnCount
	}
	
	init(
		_ items: [Item],
		isReversed: Bool = false,
		columnCount: Int = 3,
		visibleRowCount: Int? = nil,
		spacing: CGFloat = 1,
		scrollPosition: Binding<ScrollPosition>,
		@ViewBuilder content: @escaping (Item) -> Content
	) {
		self.items = isReversed ? items.reversed() : items
		self.isReversed = isReversed
		self.columnCount = columnCount
		self.visibleRowCount = visibleRowCount ?? (columnCount * 2)
		self.spacing = spacing
		self._scrollPosition = scrollPosition
		self.content = content
		self._shouldPad = State(initialValue: isReversed)
	}
	
	var body: some View {
		ScrollView {
			LazyVGrid(columns: columns, spacing: spacing) {
				if missingItems > 0 && shouldPad && safeToPad {
					ForEach(0..<missingItems, id: \.self) { _ in
						Color.clear
							.aspectRatio(1, contentMode: .fit)
					}
				}
				
				ForEach(items) { item in
					content(item)
						.id(item.id)
						.onAppear {
							if item == items[triggerIndex] {
								shouldPad = !isReversed
							}
						}
						.onDisappear {
							if item == items[triggerIndex] {
								shouldPad = isReversed
							}
						}
				}
			}
			.scrollTargetLayout()
		}
		.scrollPosition($scrollPosition)
		.defaultScrollAnchor(isReversed ? .bottom : .top)
		.onChange(of: items.count) {
			withAnimation {
				scrollPosition.scrollTo(edge: isReversed ? .bottom : .top)
			}
		}
	}
}

struct FlushPreview: Identifiable, Equatable {
	let id: Int
}

#Preview {
	@Previewable @State var scroll = ScrollPosition()
	FlushGridView((1...99).map{ FlushPreview(id: $0) }, scrollPosition: $scroll) { _ in
		RoundedRectangle(cornerRadius: 4)
			.aspectRatio(1, contentMode: .fit)
			.foregroundStyle(.secondary)
	}
}
