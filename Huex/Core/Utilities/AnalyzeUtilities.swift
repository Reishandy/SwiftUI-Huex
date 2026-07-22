//
//  AnalyzeUtilities.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 22/07/26.
//

// Using AI cause I am not implementing all this math haha...

import Foundation
import UIKit
import simd

// TODO: Cleanup unnecessary comments

// MARK: - Pixel extraction

/// Reads RGB values from `image`, stratified-sampled down to roughly
/// `maxSamples` pixels if the image has more than that. Sizing/downsampling
/// to a *source* resolution is still the caller's job (PhotoDataWorker's
/// PHImageManager fetch) — this only controls how many of those pixels
/// actually get clustered, so raising the source size to preserve small
/// accents doesn't linearly increase K-Means cost.
///
/// Draws into a device-RGB context regardless of the source's color space,
/// so wide-gamut (Display P3) photo assets get converted to sRGB before
/// pixel sampling — matching the sRGB assumption `rgbToLab` makes.
nonisolated func extractRGBVectors(from image: UIImage, maxSamples: Int = 10_000) -> [simd_float3]? {
	guard let cgImage = image.cgImage else { return nil }
	
	let width = cgImage.width
	let height = cgImage.height
	guard width > 0, height > 0 else { return nil }
	
	let bytesPerPixel = 4
	let bytesPerRow = bytesPerPixel * width
	var pixelData = [UInt8](repeating: 0, count: width * height * bytesPerPixel)
	
	let colorSpace = CGColorSpaceCreateDeviceRGB()
	guard let context = CGContext(
		data: &pixelData,
		width: width,
		height: height,
		bitsPerComponent: 8,
		bytesPerRow: bytesPerRow,
		space: colorSpace,
		bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
	) else { return nil }
	
	context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
	
	let totalPixels = width * height
	// Stride evenly across all pixels rather than reading every one, so
	// sampling stays roughly uniform across the image instead of clustering
	// samples in one region (e.g. just the top rows).
	let pixelStride = max(1, totalPixels / maxSamples)
	
	var vectors: [simd_float3] = []
	vectors.reserveCapacity(min(totalPixels, maxSamples) + 1)
	
	for pixelNumber in stride(from: 0, to: totalPixels, by: pixelStride) {
		let pixelIndex = pixelNumber * bytesPerPixel
		let r = Float(pixelData[pixelIndex])
		let g = Float(pixelData[pixelIndex + 1])
		let b = Float(pixelData[pixelIndex + 2])
		vectors.append(simd_float3(r, g, b))
	}
	
	return vectors
}

// MARK: - Stage A: K-Means++

nonisolated func runKMeansPlusPlus(pixels: [simd_float3], k: Int, maxIterations: Int = 20) -> [(centroid: simd_float3, count: Int)] {
	guard !pixels.isEmpty, k > 0 else { return [] }
	
	var centroids = [simd_float3]()
	centroids.reserveCapacity(k)
	centroids.append(pixels.randomElement()!)
	
	for _ in 1..<k {
		var distances = [Float](repeating: 0.0, count: pixels.count)
		var totalDist: Double = 0.0
		
		for i in 0..<pixels.count {
			var minSq: Float = .greatestFiniteMagnitude
			for c in centroids {
				let d = simd_distance_squared(pixels[i], c)
				if d < minSq { minSq = d }
			}
			distances[i] = minSq
			totalDist += Double(minSq)
		}
		
		if totalDist <= 0.0 {
			centroids.append(pixels.randomElement()!)
			continue
		}
		
		let target = Double.random(in: 0..<totalDist)
		var cumulative: Double = 0.0
		var selectedIndex = pixels.count - 1
		
		for i in 0..<pixels.count {
			cumulative += Double(distances[i])
			if cumulative >= target {
				selectedIndex = i
				break
			}
		}
		centroids.append(pixels[selectedIndex])
	}
	
	var clusterCounts = [Int](repeating: 0, count: k)
	
	for _ in 0..<maxIterations {
		var newCentroids = [simd_float3](repeating: simd_float3(0, 0, 0), count: k)
		var newCounts = [Int](repeating: 0, count: k)
		var maxMovement: Float = 0.0
		
		for pixel in pixels {
			var minDist: Float = .greatestFiniteMagnitude
			var bestIdx = 0
			for i in 0..<k {
				let d = simd_distance_squared(pixel, centroids[i])
				if d < minDist {
					minDist = d
					bestIdx = i
				}
			}
			newCentroids[bestIdx] += pixel
			newCounts[bestIdx] += 1
		}
		
		for i in 0..<k {
			if newCounts[i] > 0 {
				let updated = newCentroids[i] / Float(newCounts[i])
				let movement = simd_distance(centroids[i], updated)
				if movement > maxMovement { maxMovement = movement }
				centroids[i] = updated
			}
		}
		
		clusterCounts = newCounts
		if maxMovement < 0.01 { break }
	}
	
	var results: [(centroid: simd_float3, count: Int)] = []
	for i in 0..<k {
		if clusterCounts[i] > 0 {
			results.append((centroid: centroids[i], count: clusterCounts[i]))
		}
	}
	
	return results
}

// MARK: - Stage A: centroid merge (dynamic swatch count)

/// Agglomeratively merges centroids closer than `distanceThreshold` in Lab
/// space, weighted by pixel count. This is what turns a fixed, over-clustered
/// K into a variable final swatch count — a two-tone image (e.g. a flag)
/// collapses to ~2 real clusters after merge; a visually busy image with
/// genuinely distinct colors keeps most of them, since nothing merges unless
/// it's actually close. Tune `distanceThreshold` against the eval harness.
nonisolated func mergeCentroids(
	_ clusters: [(centroid: simd_float3, count: Int)],
	distanceThreshold: Float
) -> [(centroid: simd_float3, count: Int)] {
	var working = clusters
	var didMerge = true
	
	while didMerge {
		didMerge = false
		
		outer: for i in 0..<working.count {
			for j in (i + 1)..<working.count {
				let distance = simd_distance(working[i].centroid, working[j].centroid)
				if distance < distanceThreshold {
					let totalCount = working[i].count + working[j].count
					let weightedCentroid =
					(working[i].centroid * Float(working[i].count) +
					 working[j].centroid * Float(working[j].count)) / Float(totalCount)
					
					working[i] = (centroid: weightedCentroid, count: totalCount)
					working.remove(at: j)
					didMerge = true
					break outer
				}
			}
		}
	}
	
	return working
}

// MARK: - Stage A: top-level extraction

/// Full extraction pipeline for one photo. Returns swatches sorted by
/// weight descending, ready to store on `PhotoMetadata.swatches`.
nonisolated func extractPalette(
	from image: UIImage,
	initialK: Int = 14,
	mergeDistanceThreshold: Float = 6.0,
	minCoveragePercentage: Double = 0.01
) -> [Swatch] {
	guard let rgbVectors = extractRGBVectors(from: image) else { return [] }
	
	let labVectors = rgbVectors.map { rgbToLab($0) }
	let rawClusters = runKMeansPlusPlus(pixels: labVectors, k: initialK)
	let mergedClusters = mergeCentroids(rawClusters, distanceThreshold: mergeDistanceThreshold)
	
	let totalPixels = Double(mergedClusters.reduce(0) { $0 + $1.count })
	guard totalPixels > 0 else { return [] }
	
	return mergedClusters
		.map { cluster -> Swatch in
			let weight = Double(cluster.count) / totalPixels
			return Swatch.make(labCentroid: cluster.centroid, weight: weight)
		}
		.filter { $0.weight >= minCoveragePercentage }
		.sorted { $0.weight > $1.weight }
}


// MARK: - Stage B: bucketing

struct CategorizationResult {
	var bucket: ColorBucket
	var confidence: Double
	var margin: Double
}

/// Ranks swatches by chroma (weight as tiebreaker), then assigns a bucket to
/// whichever wins. This is what picks "red" over "white" for something like
/// a Japan-flag-style photo — raw pixel coverage alone would pick white.
nonisolated func categorize(
	swatches: [Swatch],
	minCoveragePercentage: Double = 0.05,
	marginThreshold: Double = 0.02,
	dominantNeutralWeight: Double = 0.40
) -> CategorizationResult {
	guard !swatches.isEmpty else {
		return CategorizationResult(bucket: .mixed, confidence: 0, margin: 0)
	}
	
	let eligible = swatches.filter { $0.weight >= minCoveragePercentage }
	
	guard !eligible.isEmpty else {
		let fallback = swatches.max(by: { $0.weight < $1.weight })!
		return CategorizationResult(bucket: bucketFor(swatch: fallback), confidence: fallback.weight, margin: 0)
	}
	
	// A large-area Black/White/Gray swatch can't win on chroma (it's ~0 by
	// definition), so a small colorful accent would otherwise always beat
	// it regardless of how dominant it visually is. Let it win outright
	// once it clears a real area threshold.
	if let dominantNeutral = eligible
		.filter({ [.black, .white, .gray].contains(bucketFor(swatch: $0)) })
		.max(by: { $0.weight < $1.weight }),
	   dominantNeutral.weight >= dominantNeutralWeight {
		return CategorizationResult(bucket: bucketFor(swatch: dominantNeutral), confidence: dominantNeutral.weight, margin: 1.0)
	}
	
	// Blended salience: chroma scaled by a weight-derived factor. A tiny
	// sliver can't win on saturation alone, but a moderately-sized area
	// with a real chroma edge still can beat something larger but duller.
	func score(_ swatch: Swatch) -> Double {
		swatch.lch.c * (0.3 + 0.7 * swatch.weight)
	}
	
	let ranked = eligible.sorted { score($0) > score($1) }
	let primary = ranked[0]
	
	let margin: Double
	if ranked.count > 1 {
		let primaryScore = score(primary)
		let runnerUpScore = score(ranked[1])
		margin = (primaryScore - runnerUpScore) / max(primaryScore, 1)
	} else {
		margin = 1.0
	}
	
	let primaryBucket = bucketFor(swatch: primary)
	
	if ranked.count > 1 && margin < marginThreshold {
		let runnerUpBucket = bucketFor(swatch: ranked[1])
		
		// Only return mixed if the competing swatches belong to DIFFERENT buckets
		if primaryBucket != runnerUpBucket {
			return CategorizationResult(bucket: .mixed, confidence: primary.weight, margin: margin)
		}
	}
	
	return CategorizationResult(bucket: primaryBucket, confidence: primary.weight, margin: margin)
}

/// LCh gates evaluated in order — lightness extremes, then chroma floor,
/// then pink/brown/purple windows, then nearest hue by circular distance.
/// Hue is only ever consulted last, since it's unstable/meaningless at low
/// chroma or extreme lightness.
nonisolated func bucketFor(
	swatch: Swatch,
	blackLightnessMax: Double = 20,
	whiteLightnessMin: Double = 90,
	whiteChromaMax: Double = 8,
	grayChromaMax: Double = 12
) -> ColorBucket {
	let l = swatch.lch.l
	let c = swatch.lch.c
	let h = swatch.lch.h
	
	if l < blackLightnessMax { return .black }
	if l > whiteLightnessMin && c < whiteChromaMax { return .white }
	if c < grayChromaMax { return .gray }
	
	// Pink — pale/pastel red-magenta, not the saturated version.
	if (h >= 330 || h <= 20) && l > 55 && c < 45 {
		return .pink
	}
	
	// Brown — a lightness/chroma modifier on orange/yellow, not a separate
	// hue. Widened from the original [20,70]/l<65 bounds: real tan, khaki,
	// cardboard, and golden-brown food tones commonly land at hue 70-100°
	// and lightness up to ~80 in Lab space (verified against actual photo
	// swatches) — the original window excluded exactly that range, so
	// these fell through to Orange/Yellow via nearest-hue instead.
	if h >= 20 && h <= 100 && l < 80 && c < 45 {
		return .brown
	}
	
	// Purple/magenta — violet through saturated magenta/berry tones. This is
	// an explicit gate rather than leaving it to nearest-hue-center distance:
	// Purple's real Lab-space hue (~320°) sits close enough to Blue's
	// (~300°) that a plain nearest-center lookup put saturated magenta
	// right on Red's doorstep instead (Red's real anchor is ~40°, but the
	// old wrong anchors of red=0°/purple=290° put a hue like 358° closer
	// to "red" by a few degrees). This range is deliberately not caught by
	// the paler Pink gate above.
	if h >= 310 && h < 360 {
		return .purple
	}
	
	return nearestHueBucket(hueDegrees: h)
}

nonisolated func nearestHueBucket(hueDegrees: Double) -> ColorBucket {
	// Centers are real Lab-space hue angles for each pure color (computed
	// via rgbToLab/labToLCh on saturated reference RGB values), not evenly
	// spaced guesses. sRGB's gamut is skewed in Lab space — e.g. pure red
	// sits at ~40°, not 0°, and pure blue sits at ~300°, not 240° — so
	// evenly-spaced anchors put real category boundaries in the wrong
	// place. This was the root cause of blue skies/oceans/screens reading
	// as Purple: the old "blue" anchor (240°) was nowhere near where blue
	// actually lives, while the old "purple" anchor (290°) was almost
	// exactly on top of it. Purple is intentionally absent here — it's
	// handled by the explicit gate in bucketFor above.
	let hueCenters: [(ColorBucket, Double)] = [
		(.red, 40),
		(.orange, 70),
		(.yellow, 100),
		(.green, 135),
		(.blue, 300)
	]
	
	return hueCenters.min { a, b in
		circularHueDistance(hueDegrees, a.1) < circularHueDistance(hueDegrees, b.1)
	}!.0
}

/// Runs Stage A then Stage B on a single already-fetched image. Returns nil
/// only if extraction produced no swatches at all (e.g. unreadable image).
nonisolated func analyzeImage(_ image: UIImage) -> (bucket: ColorBucket, swatches: [Swatch])? {
	let swatches = extractPalette(from: image)
	guard !swatches.isEmpty else { return nil }
	
	let result = categorize(swatches: swatches)
	return (bucket: result.bucket, swatches: swatches)
}
