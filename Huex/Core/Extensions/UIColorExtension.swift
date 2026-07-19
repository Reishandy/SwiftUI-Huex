//
//  UIColorExtension.swift
//  CH2-RecreateAndRemix
//
//  Created by Muhammad Akbar Reishandy on 22/04/26.
//

import Foundation
import UIKit

nonisolated extension UIColor {
	
	/// Convenience initializer with hexadecimal values.
	public convenience init?(hex: String) {
		let hexString = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
		
		var hexValue = UInt64()
		
		guard Scanner(string: hexString).scanHexInt64(&hexValue) else {
			return nil
		}
		
		let a, r, g, b: UInt64
		switch hexString.count {
		case 3: // 0xRGB
			(a, r, g, b) = (255, (hexValue >> 8) * 17, (hexValue >> 4 & 0xF) * 17, (hexValue & 0xF) * 17)
		case 6: // 0xRRGGBB
			(a, r, g, b) = (255, hexValue >> 16, hexValue >> 8 & 0xFF, hexValue & 0xFF)
		case 8: // 0xRRGGBBAA
			(r, g, b, a) = (hexValue >> 24, hexValue >> 16 & 0xFF, hexValue >> 8 & 0xFF, hexValue & 0xFF)
		default:
			(a, r, g, b) = (255, 0, 0, 0)
		}
		self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
	}
	
	/// The hexadecimal value of the color.
	public var hex: String {
		var r: CGFloat = 0
		var g: CGFloat = 0
		var b: CGFloat = 0
		var a: CGFloat = 0
		
		self.getRed(&r, green: &g, blue: &b, alpha: &a)
		
		let rInt = Int(r * 255)
		let gInt = Int(g * 255)
		let bInt = Int(b * 255)
		
		let rgb: Int = rInt << 16 | gInt << 8 | bInt << 0
		return String(format: "#%06x", rgb)
	}
	
}
