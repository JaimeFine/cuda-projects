/*
Parallel Reduction

Problem
    Implement a CUDA kernel that computes the sum of an array in parallel.

    Given an array of size N, compute:
    
        sum = x_0 + x_1 + x_2 + ... + x_(N-1)

    using parallel reduction on the GPU.

    Each thread should initially load one element from global memory.
    Threads within the same block should cooperatively reduce the values
    using shared memory until a single partial sum remains per block.

    The kernel should write one partial sum per block to an output array.
    (The final sum can be obtained by reducing these partial sums.)
*/
#include <iostream>
#include <cuda_runtime_api.h>

__global__ void calculate(float* X, float* result, int N) {
    __shared__ float sharedData[256];
    
    int tid = threadIdx.x;
    int i = blockIdx.x * blockDim.x + tid;

    sharedData[tid] = (i < N) ? X[i] : 0.0f;
    __syncthreads();

    for (int step = blockDim.x / 2; step > 0; step /= 2) {
        if (tid < step) {
            sharedData[tid] += sharedData[tid + step];
        }

        __syncthreads();
    }

    if (tid == 0) {
        result[blockIdx.x] = sharedData[0];
    }
}

int main() {
    // Initiate the data
    float* X = nullptr;
    auto N = 100;
    float* result = nullptr;

    cudaMallocManaged(&X, N * sizeof(float));
    cudaMallocManaged(&result, sizeof(float));

    for (int i = 0; i < N; i++) {
        X[i] = i;
    }

    int threads = 256;
    calculate<<<1, threads>>>(X, result, N);
    cudaDeviceSynchronize();

    std::cout << *result << std::endl;
    
    cudaFree(result);
    cudaFree(X);
    return 0;
}