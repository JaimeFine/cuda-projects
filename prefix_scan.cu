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

__global__ void scan(float* X, float* Y, int N) {
    extern __shared__ float shared[];

    int tid = threadIdx.x;
    int i = blockIdx.x * blockDim.x + tid;

    if (i < N)
        shared[tid] = X[i];
    else
        shared[tid] = 0;
    __syncthreads();
    
    for (int offset = 1; offset < blockDim.x; offset *= 2) {
        int idx = (tid + 1) * offset * 2 - 1;
        if (idx < blockDim.x)
            shared[idx] += shared[idx - offset];
        __syncthreads();
    }

    if (tid == 0)
        shared[blockDim.x - 1] = 0;

    __syncthreads();

    for (int offset = blockDim.x / 2; offset > 0; offset /= 2) {
        int idx = (tid + 1) * offset * 2 - 1;

        if (idx < blockDim.x) {
            float t = shared[idx - offset];
            shared[idx - offset] = shared[idx];
            shared[idx] += t;
        }
        __syncthreads();
    }

    if (i < N)
        Y[i] = shared[tid];
}

int main() {
    int N = 50;
    float* X = nullptr;
    float* Y = nullptr;

    cudaMallocManaged(&X, N * sizeof(float));
    cudaMallocManaged(&Y, N * sizeof(float));

    for (int i = 0; i < N; i++) {
        X[i] = i;
    }

    int threads = 256;
    int blocks = (N + threads - 1) / threads;
    scan<<<blocks, threads, threads * sizeof(float)>>>(X, Y, N);

    cudaDeviceSynchronize();

    for (int i = 0; i < N; i++) {
        std::cout << Y[i] << " ";
    }
    
    cudaFree(X);
    cudaFree(Y);

    return 0;
}