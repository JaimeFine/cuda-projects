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
#include <iostream>
#include <vector>
#include <cuda_runtime_api.h>

__global__ void histogram(float* X, float* result) {
    int workIndex = threadIdx.x + blockIdx.x * blockDim.x;
    X[workIndex] = val;
    atomicAdd(result[val], 1);
}

int main() {
    float* X;
    float* result;

    X = [1, 3, 2, 1, 0, 2, 3, 1];
    result = [];

    for (int i = 0; i < B; i++) {
        std::cout << result[i] << " ";
    }
}