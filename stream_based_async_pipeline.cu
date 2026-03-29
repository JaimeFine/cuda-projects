/*
Stream-based Async Pipeline

Problem
    Implement a CUDA program that processes an array using multiple streams
    to overlap memory transfers and computation.

    Given an input array X of size N, perform a simple operation (e.g., scale
    each element or add a constant) and store the result in Y.

    The computation should be divided into chunks. For each chunk:
        - Asynchronously copy data from host to device
        - Launch a kernel on the device
        - Asynchronously copy results back to host

    Use multiple CUDA streams to overlap:
        - host-to-device transfers
        - kernel execution
        - device-to-host transfers

Requirements
    - Use cudaStream_t to create multiple streams
    - Use cudaMemcpyAsync for memory transfers
    - Launch kernels in specific streams
    - Ensure proper synchronization before accessing final results
    - Divide the workload into chunks per stream
*/
#include <iostream>
#include <cuda_runtime_api.h>

__global__ void kernel(float* X, float* Y, int N) {
    int i = threadIdx.x + blockIdx.x * blockDim.x;
    if (i < N)
        Y[i] = X[i] * 2.0f;
}

int main() {
    float* X = nullptr;
    float* Y = nullptr;
    int N = 50;

    int chunk = 10;
    int num = N / chunk;

    cudaMallocHost(&X, N * sizeof(float));
    cudaMallocHost(&Y, N * sizeof(float));

    for (int i = 0; i < N; i++)
        X[i] = i;

    cudaStream_t streams[num];

    for (int i = 0; i < num; i++)
        cudaStreamCreate(&streams[i]);

    float* d_X[num];
    float* d_Y[num];

    for (int i = 0; i < num; i++) {
        cudaMalloc(&d_X[i], chunk * sizeof(float));
        cudaMalloc(&d_Y[i], chunk * sizeof(float));
    }

    int threads = 128;
    int blocks = (chunk + threads - 1) / threads;

    for (int i = 0; i < num; i++) {
        int s = i;
        // AI suggestion: int s = i % number of streams

        cudaMemcpyAsync(
            d_X[s], X + i * chunk,
            chunk * sizeof(float),
            cudaMemcpyHostToDevice,
            streams[s]
        );

        kernel<<<blocks, threads, 0, streams[s]>>>(d_X[s], d_Y[s], chunk);

        cudaMemcpyAsync(
            Y + i * chunk, d_Y[s],
            chunk * sizeof(float),
            cudaMemcpyDeviceToHost,
            streams[s]
        );
    }

    cudaDeviceSynchronize();

    for (int i = 0; i < N; i++) {
        std::cout << Y[i] << " ";
    }

    for (int i = 0; i < num; i++) {
        cudaFree(d_x[i]);
        cudaFree(d_Y[i]);
        cudaStreamDestroy(streams[i]);
    }

    cudaFreeHost(X);
    cudaFreeHost(Y);

    return 0;
}