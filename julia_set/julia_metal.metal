//
//  julia_metal.metal
//  julia_set
//
//  Created by Dominik Marcinkowski on 05/05/2024.
//

#include <metal_stdlib>
using namespace metal;


struct RGB {
    uchar red;  // uchar is equivalent to UInt8
    uchar green;
    uchar blue;
};


struct Params {
    int width;
    int height;
    int zoom;
    float moveX;
    float moveY;
    float cX;
    float cY;
    int maxIter;
};


kernel void julia_step(
    device RGB *outBuffer [[buffer(0)]],
    constant Params &params [[buffer(1)]],
    uint2 gid [[thread_position_in_grid]]
) {
    uint x = gid.x;
    uint y = gid.y;

    int width = params.width;
    int height = params.height;
    
    if (x < width && y < height){
        float zx = 1.5 * (float(x) - float(width) / 2.0) / (0.5 * float(params.zoom) * float(width)) + params.moveX;
        float zy = 1.5 * (float(y) - float(height) / 2.0) / (0.5 * float(params.zoom) * float(height)) + params.moveY;
        int i = params.maxIter;
        float tmp;
        
        while (zx * zx + zy * zy < 4.0 && i > 1) {
            tmp = zx * zx - zy * zy + params.cX;
            zy = 2.0 * zx * zy + params.cY;
            zx = tmp;
            i--;
        }

        RGB color;
        color.red = (i << 14) & 255;
        color.green = (i << 5) & 255;
        color.blue = (i * 8) & 255;
        
        int index = x + y * width;
        outBuffer[index] = color;
    }
}
