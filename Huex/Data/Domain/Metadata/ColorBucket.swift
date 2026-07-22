//
//  ColorBucket.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 19/07/26.
//

import SwiftUI

enum ColorBucket: String, Codable, CaseIterable, Identifiable {
	case red
	case orange
	case yellow
	case green
	case blue
	case purple
	case pink
	case brown
	case black
	case white
	case gray
	case mixed
	
	var id: String { rawValue }
	
	var displayName: String {
		switch self {
		case .red:    return "Red"
		case .orange: return "Orange"
		case .yellow: return "Yellow"
		case .green:  return "Green"
		case .blue:   return "Blue"
		case .purple: return "Purple"
		case .pink:   return "Pink"
		case .brown:  return "Brown"
		case .black:  return "Black"
		case .white:  return "White"
		case .gray:   return "Gray"
		case .mixed:  return "Mixed"
		}
	}
	
	var color: Color {
		switch self {
		case .black:  return .black
		case .blue:   return .blue
		case .brown:  return .brown
		case .gray:   return .gray
		case .green:  return .green
		case .orange: return .orange
		case .pink:   return .pink.mix(with: .white, by: 0.5)
		case .purple: return .purple
		case .red:    return .red
		case .yellow: return .yellow
		case .white:  return .white
		case .mixed:  return .gray.mix(with: .white, by: 0.5)
		}
	}
	
	var symbol: String {
		switch self {
		case .black:  return "suit.spade.fill"
		case .blue:   return "drop.fill"
		case .brown:  return "shippingbox.fill"
		case .gray:   return "wrench.and.screwdriver.fill"
		case .green:  return "leaf.fill"
		case .orange: return "carrot.fill"
		case .pink:   return "heart.fill"
		case .purple: return "crown.fill"
		case .red:    return "flame.fill"
		case .yellow: return "sparkles"
		case .white:  return "cloud.fill"
		case .mixed:  return "square.grid.2x2"
		}
	}
}
