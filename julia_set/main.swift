//
//  main.swift
//  julia_set
//
//  Created by Dominik Marcinkowski on 06/04/2024.
//

import Foundation
import Metal
import MetalKit


typealias RGB = (red: UInt8, green: UInt8, blue: UInt8)
struct Params {
    var width: Int32
    var height: Int32
    var zoom: Int32
    var moveX: Float
    var moveY: Float
    var cX: Float
    var cY: Float
    var maxIter: Int32
}


func julia_set_sequential() -> [[RGB]]{
    var array: [[RGB]] = Array(repeating: Array(repeating: (0, 0, 0), count: width), count: height)
    print("start")
    // Start time measurement
    let startTime = DispatchTime.now()

    for x in 0..<width-1{
        for y in 0..<height-1{
            array[y][x] = julia_step(x: x, y: y, width: width, height: height, zoom: zoom, moveX: moveX, moveY: moveY, cX: cX, cY: cY, maxIter: maxIter)
        }
    }

    // End time measurement
    let endTime = DispatchTime.now()
    // Calculate execution time
    let nanoTime = endTime.uptimeNanoseconds - startTime.uptimeNanoseconds
    let executionTime = Double(nanoTime) / 1_000_000_000 // in seconds
    print("Execution time: \(executionTime) seconds")

    return array
}


func julia_set_parallel(iterations: Int) -> [[RGB]]{
    var array: [[RGB]] = Array(repeating: Array(repeating: (0, 0, 0), count: width), count: height)
    print("start")
    // Start time measurement
    let startTime = DispatchTime.now()
    
    if iterations == 0{
        DispatchQueue.concurrentPerform(iterations: width * height) {
            iteration in julia_set_parallel_step(i: iteration, array: &array)
        }
    }
    else{
        let divider = width * height / iterations;
        DispatchQueue.concurrentPerform(iterations: iterations) {
            iteration in julia_set_parallel_step_group(i: iteration * divider, j: ((iteration + 1) * divider) - 1, array: &array)
        }
    }
    // End time measurement
    let endTime = DispatchTime.now()
    // Calculate execution time
    let nanoTime = endTime.uptimeNanoseconds - startTime.uptimeNanoseconds
    let executionTime = Double(nanoTime) / 1_000_000_000 // in seconds
    print("Execution time: \(executionTime) seconds")

    return array
}


func julia_set_metal() -> [[RGB]]{
    var array: [[RGB]] = Array(repeating: Array(repeating: (0, 0, 0), count: width), count: height)
    var flatArray: [RGB] = []

    for row in array {
        flatArray.append(contentsOf: row)
    }

    var params = Params(
        width: Int32(width),
        height: Int32(height),
        zoom: Int32(zoom),
        moveX: moveX,
        moveY: moveY,
        cX: cX,
        cY: cY,
        maxIter: 255
    )

    // Create a Metal device
    guard let device = MTLCreateSystemDefaultDevice() else {
        fatalError("Metal is not supported on this device")
    }

    // Load the Metal library
    guard let library = device.makeDefaultLibrary() else {
        fatalError("Unable to create Metal library")
    }

    // Load the kernel function
    guard let kernel = library.makeFunction(name: "julia_step") else {
        fatalError("Unable to find the 'julia_step' kernel function")
    }

    let computePipeline = try! device.makeComputePipelineState(function: kernel)
    let commandQueue = device.makeCommandQueue()!

    // Create buffers to hold the data on the GPU
    let arrayBuffer = device.makeBuffer(bytes: flatArray, length: MemoryLayout<RGB>.stride * width * height, options: [])
    let paramBuffer = device.makeBuffer(bytes: &params, length: MemoryLayout<Params>.stride, options: [])

    // Create a command buffer and compute command encoder
    let commandBuffer = commandQueue.makeCommandBuffer()!
    let computeEncoder = commandBuffer.makeComputeCommandEncoder()!


    // Set the pipeline and the data buffers
    computeEncoder.setComputePipelineState(computePipeline)
    computeEncoder.setBuffer(arrayBuffer, offset: 0, index: 0)
    computeEncoder.setBuffer(paramBuffer, offset: 0, index: 1)


    // Configure thread execution
    let threadGroupSize = MTLSize(width: groupSize, height: groupSize, depth: 1)
    let threadGroups = get_thread_groups(width: width, height: height, group_size: groupSize)

    computeEncoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupSize)


    // End the encoding and commit the command buffer
    computeEncoder.endEncoding()

    print("start")
    let startTime = DispatchTime.now()
    commandBuffer.commit()
    commandBuffer.waitUntilCompleted()

    let resultPointer = arrayBuffer?.contents().bindMemory(to: RGB.self, capacity: width * height)
    if let pointer = resultPointer {
        for i in 0..<(width * height) {
            array[i / width][i % width] = pointer[i]
        }
    }

    let endTime = DispatchTime.now()
    let nanoTime = endTime.uptimeNanoseconds - startTime.uptimeNanoseconds
    let executionTime = Double(nanoTime) / 1_000_000_000 // in seconds
    print("Execution time: \(executionTime) seconds")
    return array
}



let filePath = "/Users/dominikmarcinkowski/Desktop/Studia/PO/2023-2024/programowanie_async/julia_set/image.png"
createPNG(from: julia_set, filePath: filePath)
