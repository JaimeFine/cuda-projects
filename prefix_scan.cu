/*
Prefix Scan (Upsweep / Downsweep)

Problem
    Implement a block-level exclusive prefix scan over array X into Y using the parallel
    scan algorithm.

    You must use shared memory and perform the scan in two phases:

        1. Upsweep phase (build partial sums in a tree structure)
        2. Downsweep phase (propagate prefix sums)

Requirements
    - One block processes one segment of X
    - Use shared memory for intermediate values
    - Use __syncthreads() correctly between steps
    - Final result must be EXCLUSIVE scan
*/
#include <cuda_runtime_api.h>
#include <iostream>

