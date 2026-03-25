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