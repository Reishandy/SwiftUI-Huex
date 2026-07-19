//
//  Swatch.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 19/07/26.
//

import Foundation

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
}
