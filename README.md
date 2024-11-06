# COMP-426 A3: Multicore Implementation of 2D Bouncing Balls Simulation on the GPU

Name: Denis Oh

Student ID: 40208580

![BouncingBallsDemo](https://github.com/user-attachments/assets/7398048c-47db-49b0-816c-f88c7a9f2b1f)

#### How to run: (from project directory)
- `mkdir build`
- `cd build`
- `cmake ..`
- `make`
- `./BouncingBalls`

## Introduction:
This 2D bouncing balls simulation leverages GPU computing through OpenCL to achieve highly parallel processing. The simulation consists of several coloured balls moving and bouncing within a window, affected by gravity and interacting with each other upon collision. The simulation was redesigned from Assignments 1 and 2 to utilize GPU computation for improved parallelism and efficiency, processing physics calculations across concurrent threads.

## Design and Optimization:

### OpenCL Integration:
GPU Kernel Design: The computation thread from the past assignments has been transformed into an OpenCL kernel capable of running hundreds of parallel threads. Each ball's physics calculations are distributed across multiple threads, allowing for highly parallel execution on the GPU.

Memory Management: The implementation uses both global and local memory for optimal performance. Local memory is used for frequently accessed data within work groups, while global memory stores the final ball states.

### Host Program Implementation:
The host program (main.cpp) manages data transfer between CPU and GPU, kernel execution, and rendering. Key components include:

- Initialization of OpenCL context, command queues, and kernel
- Memory buffer management for ball positions, velocities, and colors
- Coordination of kernel execution and rendering cycles
- Performance monitoring and frame rate management

### Parallel Processing Structure
Work Distribution: The simulation uses 32 threads per ball, with each thread handling different aspects of the physics calculations:

- Position updates and gravity application
- Boundary collision detection
- Ball-to-ball collision detection and resolution
- Velocity updates and limits

Synchronization: The kernel uses memory barriers to ensure proper synchronization between different computation phases while minimizing synchronization overhead.

### Gravity and Motion:
- Gravity is calculated by dedicated threads for each ball
- Position updates are computed in parallel
- Velocity modifications are synchronized across multiple threads

### Handling Collisions:
- Wall Collisions: Processed in parallel with efficient boundary checking
- Ball-to-Ball Collisions: Distributed across multiple threads with proper synchronization
- Impact calculations are accumulated and applied atomically to prevent race conditions

### Rendering with OpenGL:
- Ball positions and states are read back from GPU memory
- OpenGL renders the balls using GL_TRIANGLE_FAN
- Synchronization between GPU computation and rendering is managed to maintain smooth animation

### Performance Optimizations:
- Use of local memory to reduce global memory access
- Efficient work group sizing for optimal GPU utilization
- Minimal data transfer between CPU and GPU
- Parallel collision detection and resolution
- Strategic placement of memory barriers to minimize synchronization overhead

## Conclusion:
By transitioning from CPU-based TBB to GPU-based OpenCL, we've achieved a massively parallel implementation of the 2D bouncing balls simulation. The use of GPU computing allows for hundreds of concurrent threads, significantly improving the simulation's computational capacity. The careful management of memory access patterns, synchronization, and work distribution results in efficient utilization of GPU resources while maintaining accurate physics simulation and smooth rendering.
