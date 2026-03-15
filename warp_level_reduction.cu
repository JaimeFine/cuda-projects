/*
Warp-level Reduction

Problem
    Implement a CUDA kernel that performs a warp-level reducion to
    compute the sum of values in parallel within a warp.

    Given an input array X of size N where each element represents
    a floating-point value, compute the sum of elements processed
    by threads in the same warp.

    Threads should cooperate using warp shuffle instructions to
    exchange values and accumulate the partial sums.

    The reduction should be performed entirely within the warp,
    without using shared memory or block-level synchronization.
*/
