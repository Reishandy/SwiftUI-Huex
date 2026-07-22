//
//  Swatch.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 19/07/26.
//

import Foundation
import simd

struct Swatch: Codable, Identifiable, Hashable {
	var id: String { hex }
	
	var hex: String
	var lab: LabColor
	var lch: LChColor
	var weight: Double
	var name: String?
	
	var rgb: (r: Int, g: Int, b: Int) {
		hexToRGB(hex)
	}
	
	var cmyk: (c: Int, m: Int, y: Int, k: Int) {
		rgbToCMYK(rgb)
	}
	
	var percentage: Int {
		Int((weight * 100).rounded())
	}
	
	static func make(hex: String, weight: Double = 1.0) -> Swatch {
		let rgbTuple = hexToRGB(hex)
		let rgbSimd = simd_float3(Float(rgbTuple.r), Float(rgbTuple.g), Float(rgbTuple.b))
		
		let labSimd = rgbToLab(rgbSimd)
		let lchColor = labToLCh(labSimd)
		
		let labColor = LabColor(
			l: Double(labSimd.x),
			a: Double(labSimd.y),
			b: Double(labSimd.z)
		)
		
		let formattedHex = rgbToHex(rgbSimd)
		let colorName = NameThatColor.descriptiveName(forHex: formattedHex)
		
		return Swatch(
			hex: formattedHex,
			lab: labColor,
			lch: lchColor,
			weight: weight,
			name: colorName
		)
	}
	
	nonisolated static func make(labCentroid: simd_float3, weight: Double = 1.0) -> Swatch {
		let rgb = labToRgb(labCentroid)
		let hex = rgbToHex(rgb)
		return Swatch.make(hex: hex, weight: weight)
	}
}
