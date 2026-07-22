//
//  PaletteItemView.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 22/07/26.
//

import SwiftUI

struct PaletteItemView: View {
	let swatch: Swatch
	let isExpanded: Bool
	
	private var shouldUseWhite: Bool {
		shouldUseWhiteText(onHex: swatch.hex) ?? false
	}
	
	@State private var isCopied: Bool = false
	
    var body: some View {
		HStack {
			VStack(alignment: .leading) {
				if isExpanded {
					Text(swatch.name ?? "Unknown")
						.font(.title2)
						.bold()
						.opacity(0.6)
						.padding(.top, 16)
					
					Spacer()
				}
				
				Text(swatch.hex.uppercased())
					.font(.title2)
					.bold()
					
			}
			.padding(.leading, 20)
			.padding(.bottom, isExpanded ? 14 : 0)
			
			Spacer()
			
			VStack(alignment: .trailing) {
				HStack {
					Text(isCopied ? "Copied" : "Copy")
					
					Image(systemName: isCopied ? "checkmark.circle" : "document.on.document")
						.contentTransition(.symbolEffect(.replace.magic(fallback: .downUp.byLayer), options: .nonRepeating))
				}
				.foregroundStyle(shouldUseWhite ? .white : .black)
				.padding(.top, isExpanded ? 16 : 0)
				
				if isExpanded {
					Spacer()
					
					VStack(alignment: .trailing, spacing: 4) {
						Text("\(swatch.percentage)%")
							.font(.callout)
							.foregroundStyle(shouldUseWhite ? .white : .black)
							.opacity(0.6)
						
						Text("RGB(\(swatch.rgb.r), \(swatch.rgb.g), \(swatch.rgb.b))")
							.font(.callout)
							.foregroundStyle(shouldUseWhite ? .white : .black)
							.opacity(0.6)
						
						Text("CMYK(\(swatch.cmyk.c), \(swatch.cmyk.m), \(swatch.cmyk.y), \(swatch.cmyk.k))")
							.font(.callout)
							.foregroundStyle(shouldUseWhite ? .white : .black)
							.opacity(0.6)
					}
				}
			}
			.padding(.trailing, 20)
			.padding(.bottom, isExpanded ? 14 : 0)
		}
		.foregroundStyle(shouldUseWhite ? .white : .black)
		.padding(.vertical, 12)
		.frame(maxWidth: .infinity)
		.frame(height: isExpanded ? 180 : 80)
		.background(Color(UIColor(hex: swatch.hex) ?? UIColor.lightGray))
		.clipShape(RoundedRectangle(cornerRadius: 20))
		.onTapGesture {
			withAnimation {
				UIPasteboard.general.string = swatch.hex
				isCopied = true
			}
			
			DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
				withAnimation {
					isCopied = false
				}
			}
		}
    }
}

#Preview {
	@Previewable @State var isExpanded: Bool = false
	
	PaletteItemView(swatch: .make(hex: "A8F03C", weight: 0.7), isExpanded: isExpanded)

	Button("Expand") {
		withAnimation {
			isExpanded.toggle()
		}
	}
	.buttonStyle(.borderedProminent)
}

