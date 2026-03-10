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
#include <cuda_runtime_api.h>

__global__ void histogram(int* X, int* result, int N) {
    int workIndex = threadIdx.x + blockIdx.x * blockDim.x;
    if (workIndex < N) {
        int val = X[workIndex];
        atomicAdd(&result[val], 1);
    }
}

int main() {
    const int N = 8;
    const int B = 4;

    int host_X[N] = {1, 3, 2, 1, 0, 2, 3, 1};
    int* host_result[B] = {0};

    int *device_X, *device_result;

    cudaMallocManaged(&device_X, N * sizeof(int));
    cudaMallocManaged(&device_result, B * sizeof(int));

    cudaMemcpy(device_X, host_X, N * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(device_result, host_result, B * sizeof(int), cudaMemcpyHostToDevice);

    int threads = 256;
    int blocks = (N + threads - 1) / threads;

    histogram<<<blocks, threads>>>(device_X, device_result, N);

    cudaDeviceSynchronize();

    cudaMemcpy(host_result, device_result, B * sizeof(int), cudaMemcpyDeviceToHost);

    for (int i = 0; i < B; i++) {
        std::cout << host_result[i] << " ";
    }

    std::cout << std::endl;

    cudaFree(device_X);
    cudaFree(device_result);

    return 0;
}