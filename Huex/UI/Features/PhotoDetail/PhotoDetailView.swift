//
//  PhotoDetailView.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 16/07/26.
//

import SwiftUI
import Photos
import SwiftData

struct PhotoDetailView: View {
	@Namespace private var detailNamespace
	
	@Environment(\.dismiss) private var dismiss
	@Environment(\.modelContext) private var modelContext
	@Environment(PhotoStoreManager.self) private var photoStoreManager
	
	let photoMetadatas: [PhotoMetadata]
	let namespace: Namespace.ID
	let initialPhotoID: PhotoMetadata.ID
	
	@Binding var scrollPosition: ScrollPosition
	
	@State private var activeID: PhotoMetadata.ID?
	@State private var isZoomed = false
	@State private var isToolbarVisible = true
	@State private var isPaletteSheetShown = false
	@State private var currentPaletteDetent: PresentationDetent = .medium
	
	@State private var showDeleteAlert = false
	@State private var showReanalyzeAlert = false
	@State private var moveToBucket: ColorBucket? = nil
	
	private var activePhotometadata: PhotoMetadata? {
		photoMetadatas.filter { $0.id == activeID }.first
	}
	
	init(
		photoMetadatas: [PhotoMetadata],
		initialPhotoID: PhotoMetadata.ID,
		namespace: Namespace.ID,
		scrollPosition: Binding<ScrollPosition>
	) {
		self.photoMetadatas = photoMetadatas
		self.initialPhotoID = initialPhotoID
		self.namespace = namespace
		self._scrollPosition = scrollPosition
		_activeID = State(initialValue: initialPhotoID)
	}
	
	var body: some View {
		GeometryReader { geometry in
			let size = geometry.size
			
			ScrollView(.horizontal) {
				LazyHStack(spacing: 0) {
					ForEach(photoMetadatas) { photoMetadata in
						PhotoItemView(
							phAsset: photoStoreManager.phAssets[photoMetadata.phaccessLocalIdentifier],
							photoMetadata: photoMetadata,
							targetSize: PHImageManagerMaximumSize,
							contentMode: .fit
						)
						.zoomable(isZoomed: $isZoomed, maxZoom: 10.0) {
							withAnimation {
								isToolbarVisible.toggle()
							}
						}
						.frame(width: size.width, height: size.height)
						.contentShape(Rectangle())
						.id(photoMetadata.id)
					}
				}
				.scrollTargetLayout()
			}
			.scrollIndicators(.hidden)
			.scrollTargetBehavior(.paging)
			.scrollPosition(id: $activeID)
			.onChange(of: isZoomed) { _, isNowZoomed in
				withAnimation(.easeInOut) {
					isToolbarVisible = !isNowZoomed
				}
			}
			.onChange(of: activeID) { _, newID in
				if let newID {
					scrollPosition = ScrollPosition(id: newID, anchor: .center)
					isZoomed = false
				}
			}
			.overlay(alignment: .bottom) {
				PhotoFilmstripView(photoMetadatas: photoMetadatas, activeID: $activeID)
					.padding(.bottom, 90)
					.opacity(isToolbarVisible ? 1 : 0)
					.allowsHitTesting(isToolbarVisible)
			}
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.ignoresSafeArea()
		.toolbar { detailToolbar }
		.sheet(isPresented: $isPaletteSheetShown) {
			if let activePhotometadata {
				PaletteSheetView(
					photoMetadata: activePhotometadata,
					isExpanded: currentPaletteDetent == .large || UIDevice.current.userInterfaceIdiom == .pad
				)
				.presentationDetents([.medium, .large], selection: $currentPaletteDetent)
				.presentationDragIndicator(.visible)
				.presentationSizing(.page)
				.presentationContentInteraction(.resizes)
				.navigationTransition(.zoom(sourceID: "sheetSource", in: detailNamespace))
			}
		}
		.statusBarHidden(!isToolbarVisible)
		.toolbar(isToolbarVisible ? .visible : .hidden, for: .navigationBar, .bottomBar)
		.navigationTransition(.zoom(sourceID: activeID ?? initialPhotoID, in: namespace))
		.interactiveDismissDisabled(isZoomed)
		.photoActionAlerts(
			selectedCount: 1,
			showDeleteAlert: $showDeleteAlert,
			showReanalyzeAlert: $showReanalyzeAlert,
			moveToBucket: $moveToBucket,
			onDelete: {
				if let activePhotometadata {
					Task {
						let success = await deletePhotos(localIdentifiers: [activePhotometadata.phaccessLocalIdentifier])
						if success {
							dismiss()
						}
					}
				}
			},
			onReanalyze: {
				withAnimation {
					if let activePhotometadata {
						activePhotometadata.bucketRawValue = nil
						activePhotometadata.swatches = nil
						
						try? modelContext.save()
						
						Task {
							try? await photoStoreManager.analyzePhotos()
						}
					}
				}
			},
			onMove: {
				withAnimation {
					if let activePhotometadata, let targetBucket = moveToBucket {
						activePhotometadata.bucketRawValue = targetBucket.rawValue
						
						try? modelContext.save()
					}
				}
			}
		)
	}
	
	@ToolbarContentBuilder
	private var detailToolbar: some ToolbarContent {
		if let activePhotometadata {
			ToolbarItem(placement: .principal) {
				HStack {
					Image(systemName: activePhotometadata.bucket?.symbol ?? "questionmark")
						.foregroundStyle(activePhotometadata.bucket?.color ?? .secondary)
						.shadow(radius: 4)
						.font(.caption)
					
					Text(activePhotometadata.bucket?.displayName ?? "Uncategorized")
						.bold()
				}
				.padding(12)
				.glassEffect()
			}
			
			ToolbarItem(placement: UIDevice.current.userInterfaceIdiom == .pad ? .topBarTrailing : .bottomBar) {
				// TODO: Share
				Button("Share", systemImage: "square.and.arrow.up") {
					
				}
			}
			
			ToolbarSpacer(placement: .topBarTrailing)
			
			ToolbarItem(placement: .topBarTrailing) {
				Menu {
					MoveMenuView { colorBucket in
						moveToBucket = colorBucket
					}
					
					Button("Reanalyze", systemImage: "arrow.2.squarepath") {
						showReanalyzeAlert = true
					}
					
					Button("Delete", systemImage: "trash", role: .destructive) {
						showDeleteAlert = true
					}
				} label: {
					Image(systemName: "ellipsis")
				}
			}
			
			ToolbarSpacer(placement: .bottomBar)
			
			ToolbarItem(placement: .bottomBar) {
				Button {
					isPaletteSheetShown = true
					currentPaletteDetent = .medium
				} label: {
					HStack {
						Image(systemName: "swatchpalette.fill")
							.symbolRenderingMode(.palette)
							.foregroundStyle(
								.blue,
								.green,
								.red
							)
						
						Text("Color Palette")
					}
					.font(.title3)
					.bold()
					.padding()
					.matchedTransitionSource(id: "sheetSource", in: detailNamespace)
					.gesture(
						DragGesture()
							.onEnded { value in
								if value.translation.height < -5 {
									isPaletteSheetShown = true
									currentPaletteDetent = .medium
								}
							}
					)
				}
			}
		}
	}
}

#Preview {
	@Previewable @Namespace var namespace
	
	NavigationStack {
		PhotoDetailView(
			photoMetadatas: [PhotoMetadata(phaccessLocalIdentifier: "preview-1")],
			initialPhotoID: PhotoMetadata(phaccessLocalIdentifier: "preview-1").id,
			namespace: namespace,
			scrollPosition: .constant(ScrollPosition())
		)
	}
	.environment(PhotoStoreManager())
	.modelContainer(PreviewData.container)
}
