//
//  Globals.swift
//  Assignment 2
//
//  Created by Jun Solomon on 2024-02-22.
//
import UIKit
import SwiftUI
import Combine

public class Globals {
    public static var maze: Maze = Maze(0, 0)
}

extension Comparable {
    func clamp(min: Self, max: Self) -> Self {
        return Swift.max(min, Swift.min(self, max))
    }
}
