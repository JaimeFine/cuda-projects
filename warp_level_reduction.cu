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
#include <cuda_runtime_api.h>
#include <iostream>

__inline__ __device__ float warp_reduce_sum(float val) {
    unsigned mask = 0xffffffff;

    for (int offset = 16; offset > 0; offset /= 2) {
        val += __shfl_down_sync(mask, val, offset);
    }

    return val;
}

__global__ void warp_reduce_kernel(float* X, float* out, int N) {
    int tid = blockIdx.x * blockDim.x + threadIdx.x;

    float val = 0.0f;

    if (tid < N)
        val = X[tid];

    // perform warp reduction
    val = warp_reduce_sum(val);

    // lane ID inside warp
    int lane = threadIdx.x & 31;

    // lane 0 writes result
    if (lane == 0)
        out[tid / 32] = val;
}

int main() {
    float *X, *out;
    int N = 100;

    X = nullptr;
    out = nullptr;

    cudaMallocManaged(&X, N * sizeof(float));
    cudaMallocManaged(&out, N * sizeof(float));

    for (int i = 0; i < N; i++) {
        X[i] = float(i);
    }

    int threads = 256;
    int blocks = (N + threads - 1) / threads;
    warp_reduce_kernel<<<blocks, threads>>>(X, out, N);
    cudaDeviceSynchronize();

    int numWarps = (N + 31) / 32;
    for (int i = 0; i < numWarps; i++) {
        std::cout << "Warp " << i << " sum: " << out[i] << std::endl;
    }

    cudaFree(X);
    cudaFree(out);
    
    return 0;
}