//
//  File.swift
//  
//
//  Created by Кирилл Тила on 13.07.2024.
//

import Foundation

public struct ParserParametersKey: Hashable, RawRepresentable, @unchecked Sendable {
    public var rawValue: String
    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}
