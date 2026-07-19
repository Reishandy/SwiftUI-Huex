//
//  LChColor.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 19/07/26.
//


struct LChColor: Codable, Hashable {
	var l: Double
	var c: Double
	/// Hue angle in degrees, normalized to [0, 360).
	var h: Double
}
