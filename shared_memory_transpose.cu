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