//
//  julia.swift
//  julia_set
//
//  Created by Dominik Marcinkowski on 18/04/2024.
//

import Foundation
import os.lock

func julia_step(x: Int, y: Int, width: Int, height: Int, zoom: Int, moveX: Float, moveY: Float, cX: Float, cY: Float, maxIter: Int) -> RGB{
    var zx = 1.5 * (Float(x) - Float(width) / 2) / (0.5 * Float(zoom) * Float(width)) + moveX
    var zy = 1.5 * (Float(y) - Float(height) / 2) / (0.5 * Float(zoom) * Float(height)) + moveY
    var i: Int = maxIter
    var tmp: Float

    while zx * zx + zy * zy < 4.0 && i > 1{
        tmp = zx * zx - zy * zy + cX
        zy = 2.0 * zx * zy + cY
        zx = tmp
        i -= 1
    }
    return (UInt8(i << 14 & 255), UInt8(i << 5 & 255), UInt8(i * 8 & 255))
}


var lock = os_unfair_lock()

func julia_set_parallel_step(i: Int, array: inout [[RGB]]){
    var rgb: RGB = (0, 0, 0)
    let x = i % width
    let y = i / width

    rgb = julia_step(x: x, y: y, width: width, height: height, zoom: zoom, moveX: moveX, moveY: moveY, cX: cX, cY: cY, maxIter: maxIter)

    os_unfair_lock_lock(&lock)
    array[y][x] = rgb
    os_unfair_lock_unlock(&lock)
}


func julia_set_parallel_step_group(i: Int, j: Int, array: inout [[RGB]]){
    var rgb: RGB = (0, 0, 0)

    for n in i...j{
        let x = n % width
        let y = n / width
        rgb = julia_step(x: x, y: y, width: width, height: height, zoom: zoom, moveX: moveX, moveY: moveY, cX: cX, cY: cY, maxIter: maxIter)
        os_unfair_lock_lock(&lock)
        array[y][x] = rgb
        os_unfair_lock_unlock(&lock)
    }
}
