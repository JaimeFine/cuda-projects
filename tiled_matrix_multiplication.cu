/*
Tiled Matrix Multiplication (CUDA)

Problem
    Implement a CUDA kernel to compute matrix multiplication
    using shared memory tiling.

    Given:
        A (M x K), B (K x N)

    Compute:
        C (M x N), where
        C[i][j] = sum A[i][k] * B[k][j]

    Requirements:
    - Use shared memory tiles (TILE x TILE)
    - Cooperatively load A and B into shared memory
    - Use __syncthreads() correctly
    - Loop over tiles along K dimension
    - Handle boundary conditions
*/
#include <cuda_runtime_api.h>
#include <iostream>

#define TILE 16
#define M 5
#define N 7
#define K 9

__global__ void multiply(float* A, float* B, float* C) {
    __shared__ float tileA[TILE][TILE + 1];
    __shared__ float tileB[TILE][TILE + 1];

    int col = blockIdx.x * TILE + threadIdx.x;
    int row = blockIdx.y * TILE + threadIdx.y;

    float sum = 0.0f;

    for (int t = 0; t < (K + TILE - 1) / TILE; t++) {
        if (row < M && t * TILE + threadIdx.x < K)
            tileA[threadIdx.y][threadIdx.x] =
                A[row * K + t * TILE + threadIdx.x];
        else
            tileA[threadIdx.y][threadIdx.x] = 0.0f;

        if (col < N && t * TILE + threadIdx.y < K)
            tileB[threadIdx.y][threadIdx.x] =
                B[(t * TILE + threadIdx.y) * N + col];
        else
            tileB[threadIdx.y][threadIdx.x] = 0.0f;

        __syncthreads();

        for (int k = 0; k < TILE; k++) {
            sum += tileA[threadIdx.y][k] * tileB[k][threadIdx.x];
        }

        __syncthreads();
    }

    if (row < M && col < N) {
        C[row * N + col] = sum;
    }
}

int main() {
    float* A = nullptr;
    float* B = nullptr;
    float* C = nullptr;

    cudaMallocManaged(&A, M * K * sizeof(float));
    cudaMallocManaged(&B, K * N * sizeof(float));
    cudaMallocManaged(&C, M * N * sizeof(float));

    for (int i = 0; i < M * K; i++) {
        A[i] = i;
    }

    for (int i = 0; i < K * N; i++) {
        B[i] = i;
    }

    dim3 threads(TILE, TILE);
    dim3 blocks((N + TILE - 1) / TILE, (M + TILE - 1) / TILE);

    multiply<<<blocks, threads>>>(A, B, C);

    cudaDeviceSynchronize();

    std::cout << "Matrix C:" << std::endl;
    for (int i = 0; i < M; i++) {
        for (int j = 0; j < N; j++) {
            std::cout << C[i * N + j] << " ";
        }
        std::cout << std::endl;
    }

    cudaFree(A);
    cudaFree(B);
    cudaFree(C);

    return 0;
}