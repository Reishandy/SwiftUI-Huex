// MIT License
//
// Copyright (c) 2018 David Everlöf
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE

// Modified to be a standalone helper

import Foundation

public enum NameThatColor {
	
	/// Finds the closest descriptive color name for a given RGB tuple.
	public static func descriptiveName(for rgb: (r: Int, g: Int, b: Int)) -> String {
		let targetR = Double(rgb.r)
		let targetG = Double(rgb.g)
		let targetB = Double(rgb.b)
		
		var shortestDistance = Double.greatestFiniteMagnitude
		var bestMatchingName = Resource.hexToName.first?.value ?? "Unknown"
		
		for (hex, name) in Resource.hexToName {
			let mask = 0x000000FF
			let r2 = Double((hex >> 16) & mask)
			let g2 = Double((hex >> 8) & mask)
			let b2 = Double(hex & mask)
			
			let squaredEuclideanDistance = pow(r2 - targetR, 2) + pow(g2 - targetG, 2) + pow(b2 - targetB, 2)
			
			if squaredEuclideanDistance < shortestDistance {
				shortestDistance = squaredEuclideanDistance
				bestMatchingName = name
			}
		}
		
		return bestMatchingName
	}
	
	/// Helper to directly find a name from a Hex string
	public static func descriptiveName(forHex hexString: String) -> String {
		let rgb = hexToRGB(hexString)
		return descriptiveName(for: rgb)
	}
	
	public static let allDescriptiveNames: [String] = {
		return Resource.names
	}()
	
	public static func hexStringFor(name: String) -> String {
		guard let hex = Resource.nameToHex[name] else { return "nil" }
		return String(format:"#%06X", hex)
	}
	
	private static var _sectionTitles: [Character]! = nil
	public static var sectionsTitles: [Character] = {
		_  = generate
		return _sectionTitles!
	}()
	
	private static var _sections: [Character: [String]]! = nil
	public static var sections: [Character: [String]] = {
		_  = generate
		return _sections
	}()
	
	private static let generate: () = {
		let sorted = Resource.names.sorted()
		_sections = [Character: [String]]()
		var dTemp = [Character: [String]]()
		
		sorted.forEach { name in
			guard let firstCharacter = name.first else { return }
			if dTemp[firstCharacter] == nil {
				dTemp[firstCharacter] = [String]()
			}
			dTemp[firstCharacter]!.append(name)
		}
		
		dTemp.forEach({ (arg: (key: Character, value: [String])) in
			let (key, value) = arg
			_sections[key] = value.sorted()
		})
		
		_sectionTitles = Array(_sections.keys).sorted()
	}()
}
