//
//  FlushGridView.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 16/07/26.
//

import SwiftUI

struct FlushGridView<Item: Identifiable & Equatable, Content: View>: View {
	@Environment(\.horizontalSizeClass) private var horizontalSizeClass
	
	private let items: [Item]
	private let isReversed: Bool
	private let explicitColumnCount: Int?
	private let explicitVisibleRowCount: Int?
	private let spacing: CGFloat
	@ViewBuilder private let content: (Item) -> Content
	
	@State private var shouldPad: Bool
	@Binding var scrollPosition: ScrollPosition
	@Binding var showScrollButton: Bool
	
	init(
		_ items: [Item],
		isReversed: Bool = false,
		columnCount: Int? = nil,
		visibleRowCount: Int? = nil,
		spacing: CGFloat = 1,
		scrollPosition: Binding<ScrollPosition>,
		showScrollButton: Binding<Bool> = .constant(false),
		@ViewBuilder content: @escaping (Item) -> Content
	) {
		self.items = isReversed ? items.reversed() : items
		self.isReversed = isReversed
		self.explicitColumnCount = columnCount
		self.explicitVisibleRowCount = visibleRowCount
		self.spacing = spacing
		self._scrollPosition = scrollPosition
		self._showScrollButton = showScrollButton
		self.content = content
		self._shouldPad = State(initialValue: isReversed)
	}
	
	private func computeColumnCount(for width: CGFloat) -> Int {
		if let explicit = explicitColumnCount {
			return explicit
		}
		
		if horizontalSizeClass == .compact {
			return 3
		} else {
			let targetItemWidth: CGFloat = 135
			let calculatedColumns = Int(width / targetItemWidth)
			return max(4, calculatedColumns)
		}
	}
	
	private func getColumns(count: Int) -> [GridItem] {
		Array(repeating: GridItem(.flexible(), spacing: spacing), count: count)
	}
	
	private func getMissingItems(for columnCount: Int) -> Int {
		(columnCount - (items.count % columnCount)) % columnCount
	}
	
	private func getTriggerIndex(for columnCount: Int) -> Int {
		let missing = getMissingItems(for: columnCount)
		let targetVisualIndex = isReversed ? (columnCount * 2) - 1 : (items.count - 1) - columnCount - 2
		let calculatedIndex = isReversed ? targetVisualIndex - missing : targetVisualIndex + missing
		return max(0, min(calculatedIndex, items.count - 1))
	}
	
	private func isSafeToPad(for columnCount: Int) -> Bool {
		let rowCount = explicitVisibleRowCount ?? (columnCount * 2)
		return items.count > (columnCount * rowCount) + columnCount
	}
	
	var body: some View {
		GeometryReader { geometry in
			let columnCount = computeColumnCount(for: geometry.size.width)
			let missingItems = getMissingItems(for: columnCount)
			let triggerIndex = getTriggerIndex(for: columnCount)
			let safeToPad = isSafeToPad(for: columnCount)
			
			ScrollView {
				LazyVGrid(columns: getColumns(count: columnCount), spacing: spacing) {
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
				.frame(minHeight: geometry.size.height, alignment: .top)
			}
			.scrollPosition($scrollPosition)
			.onScrollGeometryChange(for: Bool.self) { geometry in
				if isReversed {
					let maxScrollY = geometry.contentSize.height - geometry.containerSize.height
					let distanceFromBottom = maxScrollY - geometry.contentOffset.y
					return distanceFromBottom > 500
				} else {
					let distanceFromTop = geometry.contentOffset.y
					return distanceFromTop > 500
				}
			} action: { oldValue, newValue in
				showScrollButton = newValue
			}
			.defaultScrollAnchor(isReversed ? .bottom : .top)
			.onChange(of: items.count) {
				withAnimation {
					scrollPosition.scrollTo(edge: isReversed ? .bottom : .top)
				}
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
