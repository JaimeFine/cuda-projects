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