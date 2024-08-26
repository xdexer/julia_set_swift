//
//  metal_thread_group_utils.swift
//  julia_set
//
//  Created by Dominik Marcinkowski on 10/05/2024.
//

import Foundation
import Metal


func get_thread_groups(width: Int, height: Int, group_size: Int) -> MTLSize
{
    return MTLSize(width: width / group_size, height: height / group_size, depth: 1)
}
