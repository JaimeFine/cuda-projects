/*
Elementwise Map

Problem
    Implement a CUDA kernel that applies a function elementwise to an input array.
    Given an array x of size N, compute:
        y_i = x_i * x_i
    for every element in parallel on the GPU.
    Each thread should process one element.
*/
#include <cuda_runtime_api.h>
#include <cstdlib>
#include <memory.h>
#include <stdio.h>

__global__ void function(float* X, float* Y, int vectorLength) {
    int workIndex = threadIdx.x + blockIdx.x * blockDim.x;
    if (workIndex < vectorLength) {
        Y[workIndex] = X[workIndex] * X[workIndex]
    }
}