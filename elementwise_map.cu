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
#include <iostream>

__global__ void function(float* X, float* Y, int vectorLength) {
    int workIndex = threadIdx.x + blockIdx.x * blockDim.x;
    if (workIndex < vectorLength) {
        Y[workIndex] = X[workIndex] * X[workIndex];
    }
}

// AI's upgrade suggestion for larger arrays:
__global__ void function_upgrade(float* X, float* Y, int N) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    int stride = blockDim.x * gridDim.x;
    // blockDim.x * gridDim.x = total_threads

    for (int i = idx; i < N; i += stride) {
        Y[i] = X[i] * X[i];
    }
}

void calculate(float* X, float* Y, int vectorLength) {    
    int threads = 256;
    int blocks = (vectorLength + threads - 1) / threads;
    function<<<blocks, threads>>>(X, Y, vectorLength);

    cudaDeviceSynchronize();
}

int main() {
    int vectorLength = 5;
    float* X = nullptr;
    float* Y = nullptr;

    cudaMallocManaged(&X, vectorLength * sizeof(float));
    cudaMallocManaged(&Y, vectorLength * sizeof(float));

    std::cout << "Please enter " << vectorLength << " numbers:\n";
    for (int i = 0; i < vectorLength; i++) {
        std::cin >> X[i];
    }

    calculate(X, Y, vectorLength);

    for (int i = 0; i < vectorLength; i++) {
        std::cout << Y[i] << " ";
    }
    std::cout << std::endl;

    cudaFree(X);
    cudaFree(Y);

    return 0;
}