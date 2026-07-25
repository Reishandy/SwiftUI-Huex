//
//  ColorUtilities.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 19/07/26.
//

import SwiftUI
import simd

/// Converts a single sRGB channel (0...255) to linear light (0...1).
/// Shared by `rgbToLab` and `rgbToOKLab` so both start from the same
/// linearization instead of duplicating the gamma math.
nonisolated func linearizeSRGBChannel(_ c: Float) -> Float {
	let v = c / 255.0
	return v <= 0.04045 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4)
}

/// - Parameter rgb: components in 0...255
nonisolated func rgbToLab(_ rgb: simd_float3) -> simd_float3 {
	let r = linearizeSRGBChannel(rgb.x)
	let g = linearizeSRGBChannel(rgb.y)
	let b = linearizeSRGBChannel(rgb.z)
	
	// sRGB (D65) -> XYZ (D50) using Bradford Chromatic Adaptation Matrix
	let x = r * 0.4360747 + g * 0.3850649 + b * 0.1430804
	let y = r * 0.2225045 + g * 0.7168786 + b * 0.0606169
	let z = r * 0.0139322 + g * 0.0971045 + b * 0.7141733
	
	// D50 reference white
	let xn: Float = 0.96422
	let yn: Float = 1.00000
	let zn: Float = 0.82521
	
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
	
	// D50 reference white
	let xn: Float = 0.96422
	let yn: Float = 1.00000
	let zn: Float = 0.82521
	
	let x = xn * finv(fx)
	let y = yn * finv(fy)
	let z = zn * finv(fz)
	
	// XYZ (D50) -> linear sRGB (D65) using inverse Bradford Matrix
	let rLin = x *  3.1338561 + y * -1.6168667 + z * -0.4906146
	let gLin = x * -0.9787684 + y *  1.9161415 + z *  0.0334540
	let bLin = x *  0.0719453 + y * -0.2289914 + z *  1.4052427
	
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

/// Björn Ottosson's OKLab, computed straight from linear sRGB (no D50
/// adaptation step — OKLab works natively in D65, which is one of the
/// things that makes it better-behaved than Lab in the blue/purple range).
/// - Parameter rgb: components in 0...255
nonisolated func rgbToOKLab(_ rgb: simd_float3) -> simd_float3 {
	let r = linearizeSRGBChannel(rgb.x)
	let g = linearizeSRGBChannel(rgb.y)
	let b = linearizeSRGBChannel(rgb.z)
	
	let l = 0.4122214708 * Double(r) + 0.5363325363 * Double(g) + 0.0514459929 * Double(b)
	let m = 0.2119034982 * Double(r) + 0.6806995451 * Double(g) + 0.1073969566 * Double(b)
	let s = 0.0883024619 * Double(r) + 0.2817188376 * Double(g) + 0.6299787005 * Double(b)
	
	let l_ = cbrt(l)
	let m_ = cbrt(m)
	let s_ = cbrt(s)
	
	let L = 0.2104542553 * l_ + 0.7936177850 * m_ - 0.0040720468 * s_
	let a = 1.9779984951 * l_ - 2.4285922050 * m_ + 0.4505937099 * s_
	let bVal = 0.0259040371 * l_ + 0.7827717662 * m_ - 0.8086757660 * s_
	
	return simd_float3(Float(L), Float(a), Float(bVal))
}

nonisolated func oklabToOKLCh(_ oklab: simd_float3) -> OKLChColor {
	let l = Double(oklab.x)
	let a = Double(oklab.y)
	let b = Double(oklab.z)
	
	let c = sqrt(a * a + b * b)
	var h = atan2(b, a) * 180 / .pi
	if h < 0 { h += 360 }
	
	return OKLChColor(l: l, c: c, h: h)
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

nonisolated func labDistance(_ a: Swatch, _ b: Swatch) -> Double {
	let dl = a.lab.l - b.lab.l
	let da = a.lab.a - b.lab.a
	let db = a.lab.b - b.lab.b
	return sqrt(dl * dl + da * da + db * db)
}
