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

/*
__global__ void transpose(float* A, float* B, int M, int N) {
    extern __shared__ float sharedA[];
    extern __shared__ float sharedB[];

    int tid = threadIdx.x;
    int i = blockIdx.x * blockDim.x + tid;

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
*/

__global__ void transpose(float* A, float* B, int M, int N) {
    __shared__ float tile[TILE][TILE + 1];

    int x = blockIdx.x * TILE + threadIdx.x;
    int y = blockIdx.y * TILE + threadIdx.y;

    if (x < N && y < M) {
        tile[threadIdx.y][threadIdx.x] = A[y * N + x];
    }

    __syncthreads();

    int tx = blockIdx.y * TILE + threadIdx.x;
    int ty = blockIdx.x * TILE + threadIdx.y;

    if (tx < M && ty < N) {
        B[ty * M + tx] = tile[threadIdx.x][threadIdx.y];
    }
}

int main() {
    float* A = nullptr;
    float* B = nullptr;

    int M = 50;
    int N = 25;

    cudaMallocManaged(&A, M * N * sizeof(float));
    cudaMallocManaged(&B, M * N * sizeof(float));

    for (int i = 0; i < M * N; i++) {
        A[i] = i;
    }

    dim3 threads(TILE, TILE);
    dim3 blocks((N + TILE - 1) / TILE, (M + TILE - 1) / TILE);

    transpose<<<blocks, threads>>>(A, B, M, N);
    cudaDeviceSynchronize();

    for (int i = 0; i < M * N; i++) {
        std::cout << B[i] << " ";
    }

    cudaFree(A);
    cudaFree(B);

    return 0;
}