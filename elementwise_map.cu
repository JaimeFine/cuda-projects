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
        Y[workIndex] = X[workIndex] * X[workIndex];
    }
}

void memory(float* X, float* Y, int vectorLength) {
    cudaMallocManaged(&X, vectorLength * sizeof(float));
    cudaMallocManaged(&Y, vectorLength * sizeof(float));
    
    int thread = 256;
    int blocks = cuda::ceil_div(vectorLength, threads);
    function<<<blocks, threads>>>(X, Y, vectorLength);

    cudaDeviceSynchronize();

    cudaFree(X);
    cudaFree(Y);
}

int main() {
    int vectorLength = 0;
    float* X = nullptr;
    float* Y = nullptr;

    while (std::cin != getline()) {
        std::cin >> X[vectorLength];
        vectorLength++;
    }

    memory(X, Y, vectorLength);

    return 0;
}