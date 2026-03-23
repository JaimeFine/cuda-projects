/*
Shared-Memory Matrix Transpose

Problem
    Implement a CUDA kernel that performs an efficient matrix transpose
    using shared memory.

    Given an input matrix A of size M x N stored in row-major order,
    compute its transpose matrix B of size N x M such that:
    
        B[j][i] = A[i][j]

    The kernel should use shared memory to:
    - coalesce global memory reads and writes
    - avoid uncoalesced memory access patterns
    - minimize bank conflicts

    Each thread block should collaboratively load a tile of the input
    matrix into shared memory, perform the transpose within shared memory,
    and write the result back to global memory.

    Proper synchronization (__syncthreads()) must be used to ensure
    correctneww when accessing shared memory.

    You should also consider padding shared memory to avoid bank conflicts.
*/
#include <cuda_runtime_api.h>
#include <iostream>

__global__ void transpose(float* A, float* B, int M, int N) {
    extern __shared__ float sharedA[];
    extern __shared__ float sharedB[];

    int tid = threadIdx.x;
    int i = blockIdx.x * blockDim.x + tid

    sharedA[tid] = (i < M * N) ? A[i] : 0.0f;
    sharedB[tid] = (i < M * N) ? B[i] : 0.0f;
    __syncthreads();

    for (int step = 0; step < M * N; step++) {
        n = step / M;
        m = step % N;
        output = n * N + m;
        A[step] = B[output];
        __syncthreads();
    }

}

int main() {
    float* A = nullptr;
    float* B = nullptr;

    int M = 50;
    int N = 25;

    int threads = 256;
    int blocks = (N + threads - 1) / threads;

    cudaMallocManaged(&A, M * N * sizeof(float));
    cudaMallocManaged(&B, M * N * sizeof(float));

    for (int i = 0; i < M * N; i++) {
        A[i] = i;
    }

    transpose<<<blocks, threads, threads * sizeof(float)>>>(
        A, B, M, N
    );
    cudaDeviceSynchronize();

    for (int i = 0; i < M * N; i++) {
        std::cout << B[i] << " ";
    }

    cudaFree(A);
    cudaFree(B);

    return 0;
}