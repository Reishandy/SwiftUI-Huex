//
//  Zoomable.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 18/07/26.
//

import SwiftUI

struct Zoomable: ViewModifier {
	@Binding var isZoomed: Bool
	var maxZoom: CGFloat = 4.0
	var onSingleTap: () -> Void = {}
	
	@State private var currentZoom: CGFloat = 0
	@State private var totalZoom: CGFloat = 1
	@State private var currentOffset: CGSize = .zero
	@State private var totalOffset: CGSize = .zero
	
	func body(content: Content) -> some View {
		GeometryReader { geometry in
			content
				.scaleEffect(totalZoom + currentZoom)
				.offset(x: totalOffset.width + currentOffset.width,
						y: totalOffset.height + currentOffset.height)
				.contentShape(Rectangle())
				.onTapGesture(count: 2) { toggleZoom() }
				.onTapGesture(count: 1) { onSingleTap() }
				.gesture(magnify(in: geometry.size))
				.simultaneousGesture(
					pan(in: geometry.size),
					including: isZoomed ? .all : .none
				)
		}
	}
	
	private func toggleZoom() {
		withAnimation(.spring()) {
			if totalZoom > 1 {
				totalZoom = 1
				totalOffset = .zero
				isZoomed = false
			} else {
				totalZoom = min(2.5, maxZoom)
				isZoomed = true
			}
		}
	}
	
	private func magnify(in size: CGSize) -> some Gesture {
		MagnifyGesture()
			.onChanged { value in currentZoom = value.magnification - 1 }
			.onEnded { _ in
				totalZoom = min(max(totalZoom + currentZoom, 1), maxZoom)
				currentZoom = 0
				isZoomed = totalZoom > 1
				if totalZoom == 1 {
					withAnimation(.spring()) { totalOffset = .zero }
				} else {
					clamp(in: size)
				}
			}
	}
	
	private func pan(in size: CGSize) -> some Gesture {
		DragGesture()
			.onChanged { value in currentOffset = value.translation }
			.onEnded { _ in
				totalOffset.width += currentOffset.width
				totalOffset.height += currentOffset.height
				currentOffset = .zero
				clamp(in: size)
			}
	}
	
	private func clamp(in size: CGSize) {
		let maxX = max(0, (size.width * totalZoom - size.width) / 2)
		let maxY = max(0, (size.height * totalZoom - size.height) / 2)
		withAnimation(.spring()) {
			totalOffset.width = min(max(totalOffset.width, -maxX), maxX)
			totalOffset.height = min(max(totalOffset.height, -maxY), maxY)
		}
	}
}

extension View {
	func zoomable(isZoomed: Binding<Bool>, maxZoom: CGFloat = 4.0, onSingleTap: @escaping () -> Void = {}) -> some View {
		modifier(Zoomable(isZoomed: isZoomed, maxZoom: maxZoom, onSingleTap: onSingleTap))
	}
}
