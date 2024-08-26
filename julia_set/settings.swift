//
//  settings.swift
//  julia_set
//
//  Created by Dominik Marcinkowski on 13/05/2024.
//

import Foundation

let groupSize: Int = 16

let width: Int = 3840
let height: Int = 2160
let maxIter: Int = 255
let zoom: Int = 1

let cX: Float = -0.7, cY: Float = 0.27015
let moveX: Float = 0.0, moveY: Float = 0.0

//let julia_set = julia_set_sequential()
let julia_set = julia_set_parallel(iterations: 8)
//let julia_set = julia_set_metal()
