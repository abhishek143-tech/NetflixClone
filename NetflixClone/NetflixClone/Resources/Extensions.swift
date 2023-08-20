//
//  Extensions.swift
//  NetflixClone
//
//  Created by Abhishek Dilip Dhok on 20/08/23.
//

import Foundation

extension String {
    func capitalizeFirstLetter() -> String {
        return self.prefix(1).uppercased() + self.lowercased().dropFirst()
    }
}
