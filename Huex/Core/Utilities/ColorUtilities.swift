//
//  ColorUtilities.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 19/07/26.
//

import SwiftUI
import simd

/// - Parameter rgb: components in 0...255
nonisolated func rgbToLab(_ rgb: simd_float3) -> simd_float3 {
	func linearize(_ c: Float) -> Float {
		let v = c / 255.0
		return v <= 0.04045 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4)
	}
	
	let r = linearize(rgb.x)
	let g = linearize(rgb.y)
	let b = linearize(rgb.z)
	
	// sRGB -> XYZ (D65)
	let x = r * 0.4124564 + g * 0.3575761 + b * 0.1804375
	let y = r * 0.2126729 + g * 0.7151522 + b * 0.0721750
	let z = r * 0.0193339 + g * 0.1191920 + b * 0.9503041
	
	// D65 reference white
	let xn: Float = 0.95047
	let yn: Float = 1.00000
	let zn: Float = 1.08883
	
	func f(_ t: Float) -> Float {
		let delta: Float = 6.0 / 29.0
		return t > pow(delta, 3) ? pow(t, 1.0 / 3.0) : (t / (3 * delta * delta) + 4.0 / 29.0)
	}
	
	let fx = f(x / xn)
	let fy = f(y / yn)
	let fz = f(z / zn)
	
	let L = 116 * fy - 16
	let a = 500 * (fx - fy)
	let bVal = 200 * (fy - fz)
	
	return simd_float3(L, a, bVal)
}

/// - Returns: RGB components in 0...255
nonisolated func labToRgb(_ lab: simd_float3) -> simd_float3 {
	let L = lab.x, a = lab.y, b = lab.z
	
	let fy = (L + 16) / 116
	let fx = fy + a / 500
	let fz = fy - b / 200
	
	func finv(_ t: Float) -> Float {
		let delta: Float = 6.0 / 29.0
		return t > delta ? pow(t, 3) : 3 * delta * delta * (t - 4.0 / 29.0)
	}
	
	let xn: Float = 0.95047
	let yn: Float = 1.00000
	let zn: Float = 1.08883
	
	let x = xn * finv(fx)
	let y = yn * finv(fy)
	let z = zn * finv(fz)
	
	// XYZ -> linear sRGB
	let rLin = x * 3.2404542 + y * -1.5371385 + z * -0.4985314
	let gLin = x * -0.9692660 + y * 1.8760108 + z * 0.0415560
	let bLin = x * 0.0556434 + y * -0.2040259 + z * 1.0572252
	
	func gammaCorrect(_ c: Float) -> Float {
		let v = c <= 0.0031308 ? 12.92 * c : 1.055 * pow(c, 1 / 2.4) - 0.055
		return min(max(v, 0), 1) * 255
	}
	
	return simd_float3(gammaCorrect(rLin), gammaCorrect(gLin), gammaCorrect(bLin))
}

nonisolated func labToLCh(_ lab: simd_float3) -> LChColor {
	let l = Double(lab.x)
	let a = Double(lab.y)
	let b = Double(lab.z)
	
	let c = sqrt(a * a + b * b)
	var h = atan2(b, a) * 180 / .pi
	if h < 0 { h += 360 }
	
	return LChColor(l: l, c: c, h: h)
}

/// Shortest angular distance between two hue angles in degrees.
/// Without this, hues near 0°/360° (both "red") look maximally far apart
/// under naive `abs(h1 - h2)`.
nonisolated func circularHueDistance(_ h1: Double, _ h2: Double) -> Double {
	let diff = abs(h1 - h2)
	return min(diff, 360 - diff)
}

nonisolated func rgbToHex(_ rgb: simd_float3) -> String {
	let r = Int(rgb.x.rounded())
	let g = Int(rgb.y.rounded())
	let b = Int(rgb.z.rounded())
	return String(format: "#%02X%02X%02X", r, g, b)
}

nonisolated func hexToRGB(_ hex: String) -> (r: Int, g: Int, b: Int) {
	var cleaned = hex
	if cleaned.hasPrefix("#") { cleaned.removeFirst() }
	var value: UInt64 = 0
	Scanner(string: cleaned).scanHexInt64(&value)
	let r = Int((value >> 16) & 0xFF)
	let g = Int((value >> 8) & 0xFF)
	let b = Int(value & 0xFF)
	return (r, g, b)
}

nonisolated func rgbToCMYK(_ rgb: (r: Int, g: Int, b: Int)) -> (c: Int, m: Int, y: Int, k: Int) {
	let rf = Double(rgb.r) / 255
	let gf = Double(rgb.g) / 255
	let bf = Double(rgb.b) / 255
	
	let k = 1 - max(rf, gf, bf)
	if k >= 1.0 {
		return (0, 0, 0, 100)
	}
	
	let c = (1 - rf - k) / (1 - k)
	let m = (1 - gf - k) / (1 - k)
	let y = (1 - bf - k) / (1 - k)
	
	return (
		Int((c * 100).rounded()),
		Int((m * 100).rounded()),
		Int((y * 100).rounded()),
		Int((k * 100).rounded())
	)
}

func shouldUseWhiteText(onHex hex: String) -> Bool? {
	guard UIColor(hex: hex) != nil else {
		return nil
	}
	
	let rgb = hexToRGB(hex)
	let rgbSimd = simd_float3(Float(rgb.r), Float(rgb.g), Float(rgb.b))
	let lab = rgbToLab(rgbSimd)
	
	return lab.x < 50.0
}
