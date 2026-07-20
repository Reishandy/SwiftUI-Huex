//
//  Zoomable.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 18/07/26.
//

import SwiftUI

struct Zoomable: ViewModifier {
	@Binding var isZoomed: Bool
	var maxZoom: CGFloat = 10.0
	var onSingleTap: () -> Void = {}
	
	@State private var scale: CGFloat = 1.0
	@State private var lastScale: CGFloat = 1.0
	@State private var offset: CGSize = .zero
	@State private var lastOffset: CGSize = .zero
	
	func body(content: Content) -> some View {
		GeometryReader { geometry in
			let size = geometry.size
			
			content
				.scaleEffect(scale)
				.offset(offset)
				.contentShape(Rectangle())
				.onTapGesture(count: 2) { toggleZoom() }
				.onTapGesture(count: 1) { onSingleTap() }
				.gesture(magnify(in: size))
				.simultaneousGesture(
					pan(in: size),
					including: isZoomed ? .all : .none
				)
				.background(ZoomDismissGestureManager(isZoomed: isZoomed))
		}
	}
	
	private func toggleZoom() {
		withAnimation(.spring()) {
			if scale > 1.0 {
				scale = 1.0
				offset = .zero
				lastScale = 1.0
				lastOffset = .zero
				isZoomed = false
			} else {
				scale = min(3.0, maxZoom)
				lastScale = scale
				isZoomed = true
			}
		}
	}
	
	private func magnify(in size: CGSize) -> some Gesture {
		MagnifyGesture()
			.onChanged { value in
				scale = lastScale * value.magnification
				
				offset = CGSize(
					width: lastOffset.width * value.magnification,
					height: lastOffset.height * value.magnification
				)
				
				let isNowZoomed = scale > 1.0
				if isZoomed != isNowZoomed {
					isZoomed = isNowZoomed
				}
			}
			.onEnded { _ in
				if scale <= 1.0 {
					withAnimation {
						scale = 1.0
						offset = .zero
					}
					lastScale = 1.0
					lastOffset = .zero
					isZoomed = false
				} else {
					scale = min(scale, maxZoom)
					lastScale = scale
					enforceBoundaries(in: size)
					isZoomed = true
				}
			}
	}
	
	private func pan(in size: CGSize) -> some Gesture {
		DragGesture()
			.onChanged { value in
				if scale > 1.0 {
					offset = CGSize(
						width: lastOffset.width + value.translation.width,
						height: lastOffset.height + value.translation.height
					)
				}
			}
			.onEnded { _ in
				lastOffset = offset
				enforceBoundaries(in: size)
			}
	}
	
	private func enforceBoundaries(in size: CGSize) {
		let maxX = max(0, (size.width * scale - size.width) / 2)
		let maxY = max(0, (size.height * scale - size.height) / 2)
		
		withAnimation(.spring()) {
			offset.width = min(max(offset.width, -maxX), maxX)
			offset.height = min(max(offset.height, -maxY), maxY)
			lastOffset = offset
		}
	}
}

extension View {
	func zoomable(isZoomed: Binding<Bool>, maxZoom: CGFloat = 4.0, onSingleTap: @escaping () -> Void = {}) -> some View {
		modifier(Zoomable(isZoomed: isZoomed, maxZoom: maxZoom, onSingleTap: onSingleTap))
	}
}

fileprivate struct ZoomDismissGestureManager: UIViewRepresentable {
	var isZoomed: Bool
	
	func makeUIView(context: Context) -> UIView {
		let view = UIView()
		view.backgroundColor = .clear
		return view
	}
	
	func updateUIView(_ uiView: UIView, context: Context) {
		DispatchQueue.main.async {
			if let zoomViewControllerView = uiView.viewController?.view {
				zoomViewControllerView.gestureRecognizers?.forEach { gesture in
					if (gesture.name ?? "").contains("ZoomInteractive") {
						gesture.isEnabled = !isZoomed
					}
				}
			}
		}
	}
}

fileprivate extension UIView {
	var viewController: UIViewController? {
		sequence(first: self) { $0.next }
			.compactMap({ $0 as? UIViewController })
			.first
	}
}
