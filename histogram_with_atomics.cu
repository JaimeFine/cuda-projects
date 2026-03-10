/*
Parallel Histogram

Problem
    Implement a CUDA kernel that computes a histogram of an integer array.

    Given an input array X of size N where each element represents a value
    in the range [0, B-1], compute a histogram array H of size B such that:

        H_k = number of occurences of value k in X

    for all bins k in parallel on the GPU.

    Each thread should process one element from the input array and
    increment the correcponding histogram bin.
*/