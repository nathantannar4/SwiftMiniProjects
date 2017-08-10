//
//  Fruit.swift
//  UIKitExtension
//
//  Copyright © 2017 Nathan Tannar.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//
//  Created by Nathan Tannar on 7/12/17.
//

import UIKit

enum Fruit: String {
    case apple = "apple"
    case banana = "banana"
    case plum = "plum"
    case pumpkin = "pumpkin"
    case pear = "pear"
    case grapes = "grapes"
    
    func image() -> UIImage? {
        return UIImage(named: rawValue)
    }
    
    func color() -> UIColor {
        switch self {
        case .apple:
            return .red
        case .banana:
            return .yellow
        case .plum:
            return .blue
        case .pumpkin:
            return .orange
        case .pear:
            return .green
        case .grapes:
            return .purple
        }
    }
    
    static func all() -> [Fruit] {
        let fruits: [Fruit] = [.apple, .banana, .plum, .pumpkin, .grapes, .pear]
        return fruits
    }
}
