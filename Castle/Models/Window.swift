//
//  Window.swift
//  Castle
//
//  Created by Iván Estévez Nieto on 2/12/20.
//

import Foundation

enum WindowStatus: String {
    case closed = "C"
    case open = "A"
    case leftOpen = "I"
    case rightOpen = "D"
}

struct Window: Hashable {
    let id: Int
    var status = WindowStatus.open // Opened by default
    var leftOpened = true
    var rightOpened = true
    
    mutating func recalculateStatus() {
        if leftOpened && rightOpened { // Open
            status = .open
        } else if !leftOpened && !rightOpened { // Close
            status = .closed
        } else if leftOpened { // Left open
            status = .leftOpen
        } else { // Right open
            status = .rightOpen
        }
    }
}
