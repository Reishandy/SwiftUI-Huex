//
//  UIColorExtension.swift
//  CH2-RecreateAndRemix
//
//  Created by Muhammad Akbar Reishandy on 22/04/26.
//

import Foundation
import UIKit
import simd

nonisolated extension UIColor {
	
	/// Convenience initializer with hexadecimal values.
	public convenience init?(hex: String) {
		let hexString = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
		
		guard [3, 6, 8].contains(hexString.count) else {
			return nil
		}
		
		var hexValue = UInt64()
		
		guard Scanner(string: hexString).scanHexInt64(&hexValue) else {
			return nil
		}
		
		switch hexString.count {
		case 3: // 0xRGB
			let r = CGFloat((hexValue >> 8) * 17) / 255.0
			let g = CGFloat((hexValue >> 4 & 0xF) * 17) / 255.0
			let b = CGFloat((hexValue & 0xF) * 17) / 255.0
			self.init(red: r, green: g, blue: b, alpha: 1.0)
			
		case 6: // 0xRRGGBB -> Leverage ColorUtilities
			let rgb = hexToRGB(hexString)
			self.init(
				red: CGFloat(rgb.r) / 255.0,
				green: CGFloat(rgb.g) / 255.0,
				blue: CGFloat(rgb.b) / 255.0,
				alpha: 1.0
			)
			
		case 8: // 0xRRGGBBAA
			let r = CGFloat((hexValue >> 24) & 0xFF) / 255.0
			let g = CGFloat((hexValue >> 16) & 0xFF) / 255.0
			let b = CGFloat((hexValue >> 8) & 0xFF) / 255.0
			let a = CGFloat(hexValue & 0xFF) / 255.0
			self.init(red: r, green: g, blue: b, alpha: a)
			
		default:
			return nil
		}
	}
	
	/// The hexadecimal value of the color.
	public var hex: String {
		var r: CGFloat = 0
		var g: CGFloat = 0
		var b: CGFloat = 0
		var a: CGFloat = 0
		
		self.getRed(&r, green: &g, blue: &b, alpha: &a)
		
		let rgbSimd = simd_float3(Float(r * 255), Float(g * 255), Float(b * 255))
		return rgbToHex(rgbSimd)
	}
	
}
