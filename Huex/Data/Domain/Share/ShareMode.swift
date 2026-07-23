//
//  ShareMode.swift
//  Huex
//
//  Created by Muhammad Akbar Reishandy on 23/07/26.
//

enum ShareMode: String, CaseIterable, Identifiable {
	var id: Self { self }
	
	case clean = "Clean"
	case minimal = "Minimal"
	case detailed = "Detailed"
}
