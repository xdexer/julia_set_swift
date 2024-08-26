//
//  create_png.swift
//  julia_set
//
//  Created by Dominik Marcinkowski on 18/04/2024.
//
import Foundation
import CoreGraphics
import AppKit

// Function to create a PNG image from RGB pixel data
func createPNG(from pixels: [[RGB]], filePath: String) {
    let width = pixels[0].count
    let height = pixels.count
    
    // Create a bitmap context
    guard let context = CGContext(data: nil,
                                  width: width,
                                  height: height,
                                  bitsPerComponent: 8,
                                  bytesPerRow: width * 4,
                                  space: CGColorSpaceCreateDeviceRGB(),
                                  bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
        print("Error: Unable to create CGContext")
        return
    }
    
    // Draw pixels to the bitmap context
    for y in 0..<height {
        for x in 0..<width {
            let pixel = pixels[y][x]
            context.setFillColor(red: CGFloat(pixel.red) / 255.0,
                                 green: CGFloat(pixel.green) / 255.0,
                                 blue: CGFloat(pixel.blue) / 255.0,
                                 alpha: 1.0)
            context.fill(CGRect(x: x, y: height - y - 1, width: 1, height: 1))
        }
    }
    
    // Convert CGContext to CGImage
    guard let cgImage = context.makeImage() else {
        print("Error: Unable to create CGImage")
        return
    }
    
    // Convert CGImage to NSImage
    let nsImage = NSImage(cgImage: cgImage, size: NSSize(width: width, height: height))
    
    // Convert NSImage to PNG data
    guard let tiffData = nsImage.tiffRepresentation,
          let bitmapImage = NSBitmapImageRep(data: tiffData),
          let pngData = bitmapImage.representation(using: .png, properties: [:]) else {
        print("Error: Unable to create PNG data")
        return
    }

    // Write PNG data to file
    do {
        try pngData.write(to: URL(fileURLWithPath: filePath))
        print("PNG file saved successfully at: \(filePath)")
    } catch {
        print("Error saving PNG file: \(error.localizedDescription)")
    }
}
