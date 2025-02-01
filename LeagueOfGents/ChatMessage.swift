//
//  Message.swift
//  LeagueOfGents
//
//  Created by mark Slater on 2/1/25.
//
import Foundation

struct Message: Identifiable {
    var id = UUID()
    var text: String
    var isUser: Bool
}

